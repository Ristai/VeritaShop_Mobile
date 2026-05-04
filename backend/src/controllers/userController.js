const User = require('../models/User');
const { successResponse, errorResponse } = require('../utils/response');

// @desc    Get user profile
// @route   GET /api/users/profile
const getProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    
    return successResponse(res, {
      id: user._id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      phone: user.phone,
      addresses: user.addresses,
      createdAt: user.createdAt,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
const updateProfile = async (req, res, next) => {
  try {
    const { name, phone, avatar } = req.body;
    
    const updateData = {};
    if (name) updateData.name = name;
    if (phone) updateData.phone = phone;
    if (avatar) updateData.avatar = avatar;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    );

    return successResponse(res, {
      id: user._id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      phone: user.phone,
      addresses: user.addresses,
    }, 'Cập nhật thông tin thành công');
  } catch (error) {
    next(error);
  }
};

// @desc    Add new address
// @route   POST /api/users/addresses
const addAddress = async (req, res, next) => {
  try {
    const { fullName, phone, province, district, ward, streetAddress, isDefault } = req.body;

    const user = await User.findById(req.user._id);

    // If new address is default, remove default from others
    if (isDefault) {
      user.addresses.forEach(addr => {
        addr.isDefault = false;
      });
    }

    // If this is first address, make it default
    const makeDefault = user.addresses.length === 0 ? true : isDefault;

    user.addresses.push({
      fullName,
      phone,
      province,
      district,
      ward,
      streetAddress,
      isDefault: makeDefault,
    });

    await user.save();

    return successResponse(res, {
      addresses: user.addresses,
    }, 'Thêm địa chỉ thành công', 201);
  } catch (error) {
    next(error);
  }
};

// @desc    Update address
// @route   PUT /api/users/addresses/:addressId
const updateAddress = async (req, res, next) => {
  try {
    const { addressId } = req.params;
    const { fullName, phone, province, district, ward, streetAddress, isDefault } = req.body;

    const user = await User.findById(req.user._id);
    const address = user.addresses.id(addressId);

    if (!address) {
      return errorResponse(res, 'Không tìm thấy địa chỉ', 404, 'ADDRESS_NOT_FOUND');
    }

    // If updating to default, remove default from others
    if (isDefault) {
      user.addresses.forEach(addr => {
        addr.isDefault = false;
      });
    }

    // Update fields
    if (fullName) address.fullName = fullName;
    if (phone) address.phone = phone;
    if (province) address.province = province;
    if (district) address.district = district;
    if (ward) address.ward = ward;
    if (streetAddress) address.streetAddress = streetAddress;
    if (isDefault !== undefined) address.isDefault = isDefault;

    await user.save();

    return successResponse(res, {
      addresses: user.addresses,
    }, 'Cập nhật địa chỉ thành công');
  } catch (error) {
    next(error);
  }
};

// @desc    Delete address
// @route   DELETE /api/users/addresses/:addressId
const deleteAddress = async (req, res, next) => {
  try {
    const { addressId } = req.params;

    const user = await User.findById(req.user._id);
    const address = user.addresses.id(addressId);

    if (!address) {
      return errorResponse(res, 'Không tìm thấy địa chỉ', 404, 'ADDRESS_NOT_FOUND');
    }

    const wasDefault = address.isDefault;
    address.deleteOne();

    // If deleted address was default, make first remaining address default
    if (wasDefault && user.addresses.length > 0) {
      user.addresses[0].isDefault = true;
    }

    await user.save();

    return successResponse(res, {
      addresses: user.addresses,
    }, 'Xóa địa chỉ thành công');
  } catch (error) {
    next(error);
  }
};

// @desc    Change password
// @route   PUT /api/users/password
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return errorResponse(res, 'Vui lòng nhập đầy đủ thông tin', 400, 'MISSING_FIELDS');
    }

    if (newPassword.length < 6) {
      return errorResponse(res, 'Mật khẩu mới ít nhất 6 ký tự', 400, 'WEAK_PASSWORD');
    }

    const user = await User.findById(req.user._id).select('+password');

    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      return errorResponse(res, 'Mật khẩu hiện tại không đúng', 400, 'WRONG_PASSWORD');
    }

    user.password = newPassword;
    await user.save();

    return successResponse(res, null, 'Đổi mật khẩu thành công');
  } catch (error) {
    next(error);
  }
};

// ============== PIN MANAGEMENT ==============

// @desc    Set or update PIN
// @route   POST /api/users/pin
const setPin = async (req, res, next) => {
  try {
    const { pinHash } = req.body;

    if (!pinHash) {
      return errorResponse(res, 'Vui lòng cung cấp mã PIN', 400, 'MISSING_PIN_HASH');
    }

    // Validate pinHash format (should be SHA-256 hash - 64 hex chars)
    if (!/^[a-f0-9]{64}$/i.test(pinHash)) {
      return errorResponse(res, 'Mã PIN không hợp lệ', 400, 'INVALID_PIN_HASH');
    }

    await User.findByIdAndUpdate(req.user._id, {
      pinHash: pinHash,
      pinEnabled: true,
    });

    return successResponse(res, {
      pinEnabled: true,
    }, 'Đã thiết lập mã PIN');
  } catch (error) {
    next(error);
  }
};

// @desc    Verify PIN
// @route   POST /api/users/pin/verify
const verifyPin = async (req, res, next) => {
  try {
    const { pinHash } = req.body;

    if (!pinHash) {
      return errorResponse(res, 'Vui lòng cung cấp mã PIN', 400, 'MISSING_PIN_HASH');
    }

    const user = await User.findById(req.user._id).select('+pinHash');

    if (!user.pinHash) {
      return errorResponse(res, 'Chưa thiết lập mã PIN', 400, 'PIN_NOT_SET');
    }

    const isValid = user.pinHash === pinHash;

    return successResponse(res, {
      valid: isValid,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Toggle PIN enabled/disabled
// @route   PUT /api/users/pin/toggle
const togglePin = async (req, res, next) => {
  try {
    const { enabled } = req.body;

    if (typeof enabled !== 'boolean') {
      return errorResponse(res, 'Vui lòng cung cấp trạng thái', 400, 'MISSING_ENABLED');
    }

    // If enabling, check if PIN is set
    if (enabled) {
      const user = await User.findById(req.user._id).select('+pinHash');
      if (!user.pinHash) {
        return errorResponse(res, 'Chưa thiết lập mã PIN', 400, 'PIN_NOT_SET');
      }
    }

    await User.findByIdAndUpdate(req.user._id, {
      pinEnabled: enabled,
    });

    return successResponse(res, {
      pinEnabled: enabled,
    }, enabled ? 'Đã bật khóa PIN' : 'Đã tắt khóa PIN');
  } catch (error) {
    next(error);
  }
};

// @desc    Delete PIN
// @route   DELETE /api/users/pin
const deletePin = async (req, res, next) => {
  try {
    await User.findByIdAndUpdate(req.user._id, {
      pinHash: null,
      pinEnabled: false,
    });

    return successResponse(res, null, 'Đã xóa mã PIN');
  } catch (error) {
    next(error);
  }
};

// @desc    Get PIN status
// @route   GET /api/users/pin/status
const getPinStatus = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select('+pinHash');

    return successResponse(res, {
      pinEnabled: user.pinEnabled || false,
      hasPinSet: !!user.pinHash,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProfile,
  updateProfile,
  addAddress,
  updateAddress,
  deleteAddress,
  changePassword,
  setPin,
  verifyPin,
  togglePin,
  deletePin,
  getPinStatus,
};
