const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  getCart,
  addToCart,
  updateCartItem,
  removeCartItem,
  clearCart,
} = require('../controllers/cartController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// All cart routes require authentication
router.use(auth);

// Validation rules
const addToCartValidation = [
  body('productId')
    .notEmpty().withMessage('Vui lòng chọn sản phẩm')
    .isMongoId().withMessage('ID sản phẩm không hợp lệ'),
  body('quantity')
    .optional()
    .isInt({ min: 1 }).withMessage('Số lượng phải là số nguyên dương'),
  body('color')
    .notEmpty().withMessage('Vui lòng chọn màu sắc'),
  body('color.name')
    .notEmpty().withMessage('Tên màu không được trống'),
];

const updateCartValidation = [
  body('quantity')
    .notEmpty().withMessage('Vui lòng nhập số lượng')
    .isInt({ min: 0 }).withMessage('Số lượng không hợp lệ'),
];

// Routes
router.get('/', getCart);
router.post('/', addToCartValidation, validate, addToCart);
router.put('/:itemId', updateCartValidation, validate, updateCartItem);
router.delete('/:itemId', removeCartItem);
router.delete('/', clearCart);

module.exports = router;
