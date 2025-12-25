const { verifyToken } = require('../utils/jwt');
const { errorResponse } = require('../utils/response');
const User = require('../models/User');

const adminAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse(res, 'Vui lòng đăng nhập', 401, 'UNAUTHORIZED');
    }
    
    const token = authHeader.split(' ')[1];
    const decoded = verifyToken(token);
    
    if (!decoded) {
      return errorResponse(res, 'Token không hợp lệ hoặc đã hết hạn', 401, 'TOKEN_EXPIRED');
    }
    
    const user = await User.findById(decoded.userId).select('-password');
    
    if (!user) {
      return errorResponse(res, 'Người dùng không tồn tại', 401, 'USER_NOT_FOUND');
    }
    
    if (user.role !== 'admin') {
      return errorResponse(res, 'Bạn không có quyền truy cập admin', 403, 'FORBIDDEN');
    }
    
    if (!user.isActive) {
      return errorResponse(res, 'Tài khoản đã bị khóa', 403, 'ACCOUNT_DISABLED');
    }
    
    req.user = user;
    next();
  } catch (error) {
    return errorResponse(res, 'Lỗi xác thực admin', 401, 'AUTH_ERROR');
  }
};

module.exports = { adminAuth };
