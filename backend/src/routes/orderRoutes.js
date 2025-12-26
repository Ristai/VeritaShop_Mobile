const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  createOrder,
  getOrders,
  getOrderById,
  getOrderByNumber,
  cancelOrder,
  reorder,
} = require('../controllers/orderController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// All order routes require authentication
router.use(auth);

// Validation rules
const createOrderValidation = [
  body('shippingAddress').notEmpty().withMessage('Vui lòng nhập địa chỉ giao hàng'),
  body('shippingAddress.fullName').notEmpty().withMessage('Vui lòng nhập họ tên'),
  body('shippingAddress.phone')
    .notEmpty().withMessage('Vui lòng nhập số điện thoại')
    .matches(/^[0-9]{10,11}$/).withMessage('Số điện thoại không hợp lệ'),
  body('shippingAddress.province').notEmpty().withMessage('Vui lòng chọn tỉnh/thành phố'),
  body('shippingAddress.district').notEmpty().withMessage('Vui lòng chọn quận/huyện'),
  body('shippingAddress.ward').notEmpty().withMessage('Vui lòng chọn phường/xã'),
  body('shippingAddress.streetAddress').notEmpty().withMessage('Vui lòng nhập địa chỉ cụ thể'),
  body('paymentMethod')
    .optional()
    .isIn(['COD', 'MoMo', 'VNPay', 'ZaloPay', 'Card'])
    .withMessage('Phương thức thanh toán không hợp lệ'),
];

// Routes
router.post('/', createOrderValidation, validate, createOrder);
router.get('/', getOrders);
router.get('/number/:orderNumber', getOrderByNumber);
router.get('/:id', getOrderById);
router.put('/:id/cancel', cancelOrder);
router.post('/:id/reorder', reorder);

module.exports = router;
