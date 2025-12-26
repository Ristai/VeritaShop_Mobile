const { errorResponse } = require('../utils/response');

const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const details = Object.values(err.errors).map(e => e.message);
    return errorResponse(res, 'Dữ liệu không hợp lệ', 400, 'VALIDATION_ERROR', details);
  }

  // Mongoose duplicate key error
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return errorResponse(res, `${field} đã tồn tại`, 400, 'DUPLICATE_ERROR');
  }

  // Mongoose CastError (invalid ObjectId)
  if (err.name === 'CastError') {
    return errorResponse(res, 'ID không hợp lệ', 400, 'INVALID_ID');
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return errorResponse(res, 'Token không hợp lệ', 401, 'INVALID_TOKEN');
  }

  if (err.name === 'TokenExpiredError') {
    return errorResponse(res, 'Token đã hết hạn', 401, 'TOKEN_EXPIRED');
  }

  // CORS error
  if (err.message === 'Not allowed by CORS') {
    return errorResponse(res, 'Không được phép truy cập', 403, 'CORS_ERROR');
  }

  // Default error
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Lỗi server';
  
  return errorResponse(res, message, statusCode, 'SERVER_ERROR');
};

const notFound = (req, res) => {
  return errorResponse(res, `Không tìm thấy route: ${req.originalUrl}`, 404, 'NOT_FOUND');
};

module.exports = { errorHandler, notFound };
