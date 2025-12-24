const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { 
  getProfile, 
  updateProfile, 
  addAddress, 
  updateAddress, 
  deleteAddress,
  changePassword 
} = require('../controllers/userController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Validation rules
const updateProfileValidation = [
  body('name')
    .optional()
    .trim()
    .isLength({ max: 50 }).withMessage('Tên không quá 50 ký tự'),
  body('phone')
    .optional()
    .trim()
    .matches(/^[0-9]{10,11}$/).withMessage('Số điện thoại không hợp lệ'),
];

const addressValidation = [
  body('fullName')
    .trim()
    .notEmpty().withMessage('Vui lòng nhập họ tên'),
  body('phone')
    .trim()
    .notEmpty().withMessage('Vui lòng nhập số điện thoại')
    .matches(/^[0-9]{10,11}$/).withMessage('Số điện thoại không hợp lệ'),
  body('province')
    .trim()
    .notEmpty().withMessage('Vui lòng chọn tỉnh/thành phố'),
  body('district')
    .trim()
    .notEmpty().withMessage('Vui lòng chọn quận/huyện'),
  body('ward')
    .trim()
    .notEmpty().withMessage('Vui lòng chọn phường/xã'),
  body('streetAddress')
    .trim()
    .notEmpty().withMessage('Vui lòng nhập địa chỉ cụ thể'),
];

const changePasswordValidation = [
  body('currentPassword')
    .notEmpty().withMessage('Vui lòng nhập mật khẩu hiện tại'),
  body('newPassword')
    .notEmpty().withMessage('Vui lòng nhập mật khẩu mới')
    .isLength({ min: 6 }).withMessage('Mật khẩu mới ít nhất 6 ký tự'),
];

// All routes require authentication
router.use(auth);

// Profile routes
router.get('/profile', getProfile);
router.put('/profile', updateProfileValidation, validate, updateProfile);

// Address routes
router.post('/addresses', addressValidation, validate, addAddress);
router.put('/addresses/:addressId', updateAddress);
router.delete('/addresses/:addressId', deleteAddress);

// Password route
router.put('/password', changePasswordValidation, validate, changePassword);

module.exports = router;
