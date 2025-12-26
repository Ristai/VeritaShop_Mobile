const Coupon = require('../models/Coupon');
const { successResponse, errorResponse } = require('../utils/response');

// @desc    Get all available coupons for user
// @route   GET /api/coupons
const getCoupons = async (req, res, next) => {
  try {
    const now = new Date();
    
    const coupons = await Coupon.find({
      isActive: true,
      startDate: { $lte: now },
      endDate: { $gte: now },
      $or: [
        { usageLimit: null },
        { $expr: { $lt: ['$usedCount', '$usageLimit'] } }
      ]
    }).select('-usedByUsers');

    return successResponse(res, coupons);
  } catch (error) {
    next(error);
  }
};

// @desc    Validate and apply coupon
// @route   POST /api/coupons/apply
const applyCoupon = async (req, res, next) => {
  try {
    const { code, orderAmount } = req.body;
    const userId = req.user._id;

    if (!code) {
      return errorResponse(res, 'Vui lòng nhập mã giảm giá', 400, 'MISSING_CODE');
    }

    const coupon = await Coupon.findOne({ code: code.toUpperCase() });
    
    if (!coupon) {
      return errorResponse(res, 'Mã giảm giá không tồn tại', 404, 'COUPON_NOT_FOUND');
    }

    const validation = coupon.isValid(userId, orderAmount || 0);
    if (!validation.valid) {
      return errorResponse(res, validation.message, 400, 'COUPON_INVALID');
    }

    const discountAmount = coupon.calculateDiscount(orderAmount || 0);

    return successResponse(res, {
      coupon: {
        id: coupon._id,
        code: coupon.code,
        description: coupon.description,
        discountType: coupon.discountType,
        discountValue: coupon.discountValue,
        maxDiscountAmount: coupon.maxDiscountAmount,
        minOrderAmount: coupon.minOrderAmount,
      },
      discountAmount,
      finalAmount: Math.max(0, (orderAmount || 0) - discountAmount),
    }, 'Áp dụng mã giảm giá thành công');
  } catch (error) {
    next(error);
  }
};

// @desc    Remove applied coupon
// @route   DELETE /api/coupons/remove
const removeCoupon = async (req, res, next) => {
  try {
    return successResponse(res, null, 'Đã xóa mã giảm giá');
  } catch (error) {
    next(error);
  }
};

// @desc    Mark coupon as used (called after successful order)
// @route   POST /api/coupons/use
const useCoupon = async (req, res, next) => {
  try {
    const { couponId } = req.body;
    const userId = req.user._id;

    const coupon = await Coupon.findById(couponId);
    if (!coupon) {
      return errorResponse(res, 'Mã giảm giá không tồn tại', 404, 'COUPON_NOT_FOUND');
    }

    coupon.usedCount += 1;
    coupon.usedByUsers.push({ user: userId });
    await coupon.save();

    return successResponse(res, null, 'Đã sử dụng mã giảm giá');
  } catch (error) {
    next(error);
  }
};

// @desc    Get coupon by code (public)
// @route   GET /api/coupons/:code
const getCouponByCode = async (req, res, next) => {
  try {
    const { code } = req.params;
    
    const coupon = await Coupon.findOne({ 
      code: code.toUpperCase(),
      isActive: true,
    }).select('-usedByUsers');

    if (!coupon) {
      return errorResponse(res, 'Mã giảm giá không tồn tại', 404, 'COUPON_NOT_FOUND');
    }

    return successResponse(res, coupon);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getCoupons,
  applyCoupon,
  removeCoupon,
  useCoupon,
  getCouponByCode,
};
