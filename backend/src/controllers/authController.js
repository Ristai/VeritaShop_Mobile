const User = require('../models/User');
const crypto = require('crypto');
const { generateAccessToken, generateRefreshToken, verifyToken } = require('../utils/jwt');
const { successResponse, errorResponse } = require('../utils/response');

// @desc    Register new user
// @route   POST /api/auth/register
const register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    // Check if user exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return errorResponse(res, 'Email đã được sử dụng', 400, 'EMAIL_EXISTS');
    }

    // Create user
    const user = await User.create({ name, email, password });

    // Generate tokens
    const accessToken = generateAccessToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    // Save refresh token to database
    user.refreshToken = refreshToken;
    await user.save();

    return successResponse(res, {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
      },
      accessToken,
      refreshToken,
    }, 'Đăng ký thành công', 201);
  } catch (error) {
    next(error);
  }
};

// @desc    Login user
// @route   POST /api/auth/login
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return errorResponse(res, 'Vui lòng nhập email và mật khẩu', 400, 'MISSING_FIELDS');
    }

    // Find user and include password
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return errorResponse(res, 'Email hoặc mật khẩu không đúng', 401, 'INVALID_CREDENTIALS');
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return errorResponse(res, 'Email hoặc mật khẩu không đúng', 401, 'INVALID_CREDENTIALS');
    }

    // Check if user is active
    if (!user.isActive) {
      return errorResponse(res, 'Tài khoản đã bị khóa', 403, 'ACCOUNT_DISABLED');
    }

    // Generate tokens
    const accessToken = generateAccessToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    // Save refresh token
    user.refreshToken = refreshToken;
    await user.save();

    return successResponse(res, {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
        phone: user.phone,
        addresses: user.addresses,
      },
      accessToken,
      refreshToken,
    }, 'Đăng nhập thành công');
  } catch (error) {
    next(error);
  }
};

// @desc    Refresh access token
// @route   POST /api/auth/refresh
const refresh = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return errorResponse(res, 'Refresh token không được cung cấp', 400, 'MISSING_TOKEN');
    }

    // Verify refresh token
    const decoded = verifyToken(refreshToken);
    if (!decoded) {
      return errorResponse(res, 'Refresh token không hợp lệ hoặc đã hết hạn', 401, 'INVALID_REFRESH_TOKEN');
    }

    // Find user with this refresh token
    const user = await User.findOne({ 
      _id: decoded.userId, 
      refreshToken: refreshToken 
    }).select('+refreshToken');

    if (!user) {
      return errorResponse(res, 'Refresh token không hợp lệ', 401, 'INVALID_REFRESH_TOKEN');
    }

    // Generate new tokens
    const newAccessToken = generateAccessToken(user._id);
    const newRefreshToken = generateRefreshToken(user._id);

    // Update refresh token in database
    user.refreshToken = newRefreshToken;
    await user.save();

    return successResponse(res, {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    }, 'Token đã được làm mới');
  } catch (error) {
    next(error);
  }
};

// @desc    Logout user
// @route   POST /api/auth/logout
const logout = async (req, res, next) => {
  try {
    // Clear refresh token from database
    await User.findByIdAndUpdate(req.user._id, { refreshToken: null });

    return successResponse(res, null, 'Đăng xuất thành công');
  } catch (error) {
    next(error);
  }
};

// @desc    Get current user info
// @route   GET /api/auth/me
const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    
    return successResponse(res, {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
        phone: user.phone,
        addresses: user.addresses,
        createdAt: user.createdAt,
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Forgot password - send reset code
// @route   POST /api/auth/forgot-password
const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      return errorResponse(res, 'Vui lòng nhập email', 400, 'MISSING_EMAIL');
    }

    const user = await User.findOne({ email });
    if (!user) {
      return errorResponse(res, 'Email không tồn tại trong hệ thống', 404, 'EMAIL_NOT_FOUND');
    }

    // Generate reset token (6 character code)
    const resetCode = user.generateResetToken();
    await user.save();

    // In production, send email here
    // For demo, return the code (remove in production!)
    console.log(`Reset code for ${email}: ${resetCode}`);

    return successResponse(res, {
      message: 'Mã xác nhận đã được gửi đến email của bạn',
      // Remove this in production - only for testing
      resetCode: process.env.NODE_ENV === 'development' ? resetCode : undefined,
    }, 'Vui lòng kiểm tra email');
  } catch (error) {
    next(error);
  }
};

// @desc    Verify reset code
// @route   POST /api/auth/verify-reset-code
const verifyResetCode = async (req, res, next) => {
  try {
    const { email, code } = req.body;

    if (!email || !code) {
      return errorResponse(res, 'Vui lòng nhập email và mã xác nhận', 400, 'MISSING_FIELDS');
    }

    const hashedCode = crypto
      .createHash('sha256')
      .update(code.toUpperCase())
      .digest('hex');

    const user = await User.findOne({
      email,
      resetPasswordToken: hashedCode,
      resetPasswordExpires: { $gt: Date.now() },
    }).select('+resetPasswordToken +resetPasswordExpires');

    if (!user) {
      return errorResponse(res, 'Mã xác nhận không hợp lệ hoặc đã hết hạn', 400, 'INVALID_CODE');
    }

    return successResponse(res, {
      valid: true,
      message: 'Mã xác nhận hợp lệ',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Reset password with code
// @route   POST /api/auth/reset-password
const resetPassword = async (req, res, next) => {
  try {
    const { email, code, newPassword } = req.body;

    if (!email || !code || !newPassword) {
      return errorResponse(res, 'Vui lòng nhập đầy đủ thông tin', 400, 'MISSING_FIELDS');
    }

    if (newPassword.length < 6) {
      return errorResponse(res, 'Mật khẩu mới phải có ít nhất 6 ký tự', 400, 'PASSWORD_TOO_SHORT');
    }

    const hashedCode = crypto
      .createHash('sha256')
      .update(code.toUpperCase())
      .digest('hex');

    const user = await User.findOne({
      email,
      resetPasswordToken: hashedCode,
      resetPasswordExpires: { $gt: Date.now() },
    }).select('+resetPasswordToken +resetPasswordExpires +password');

    if (!user) {
      return errorResponse(res, 'Mã xác nhận không hợp lệ hoặc đã hết hạn', 400, 'INVALID_CODE');
    }

    // Update password
    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    return successResponse(res, null, 'Đặt lại mật khẩu thành công');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  refresh,
  logout,
  getMe,
  forgotPassword,
  verifyResetCode,
  resetPassword,
};
