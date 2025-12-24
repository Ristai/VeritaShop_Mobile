const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  getCoupons,
  applyCoupon,
  removeCoupon,
  useCoupon,
  getCouponByCode,
} = require('../controllers/couponController');
const { auth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Public routes
router.get('/:code', getCouponByCode);

// Protected routes
router.use(auth);

router.get('/', getCoupons);

router.post('/apply', [
  body('code').notEmpty().withMessage('Vui lòng nhập mã giảm giá'),
  body('orderAmount').optional().isNumeric().withMessage('Giá trị đơn hàng không hợp lệ'),
], validate, applyCoupon);

router.delete('/remove', removeCoupon);

router.post('/use', [
  body('couponId').notEmpty().withMessage('Vui lòng cung cấp ID mã giảm giá'),
], validate, useCoupon);

module.exports = router;
