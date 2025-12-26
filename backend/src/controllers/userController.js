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

module.exports = {
  getProfile,
  updateProfile,
  addAddress,
  updateAddress,
  deleteAddress,
  changePassword,
};
