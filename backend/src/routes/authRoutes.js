const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { register, login, refresh, logout, getMe, forgotPassword, verifyResetCode, resetPassword } = require('../controllers/authController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Validation rules
const registerValidation = [
  body('name')
    .trim()
    .notEmpty().withMessage('Vui lòng nhập tên')
    .isLength({ max: 50 }).withMessage('Tên không quá 50 ký tự'),
  body('email')
    .trim()
    .notEmpty().withMessage('Vui lòng nhập email')
    .isEmail().withMessage('Email không hợp lệ')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Vui lòng nhập mật khẩu')
    .isLength({ min: 6 }).withMessage('Mật khẩu ít nhất 6 ký tự'),
];

const loginValidation = [
  body('email')
    .trim()
    .notEmpty().withMessage('Vui lòng nhập email')
    .isEmail().withMessage('Email không hợp lệ')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Vui lòng nhập mật khẩu'),
];

const refreshValidation = [
  body('refreshToken')
    .notEmpty().withMessage('Refresh token không được cung cấp'),
];

// Routes
router.post('/register', registerValidation, validate, register);
router.post('/login', loginValidation, validate, login);
router.post('/refresh', refreshValidation, validate, refresh);
router.post('/logout', auth, logout);
router.get('/me', auth, getMe);

// Forgot password routes
router.post('/forgot-password', [
  body('email').isEmail().withMessage('Email không hợp lệ'),
], validate, forgotPassword);

router.post('/verify-reset-code', [
  body('email').isEmail().withMessage('Email không hợp lệ'),
  body('code').notEmpty().withMessage('Vui lòng nhập mã xác nhận'),
], validate, verifyResetCode);

router.post('/reset-password', [
  body('email').isEmail().withMessage('Email không hợp lệ'),
  body('code').notEmpty().withMessage('Vui lòng nhập mã xác nhận'),
  body('newPassword').isLength({ min: 6 }).withMessage('Mật khẩu mới ít nhất 6 ký tự'),
], validate, resetPassword);

module.exports = router;
