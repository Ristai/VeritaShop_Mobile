const mongoose = require('mongoose');

const couponSchema = new mongoose.Schema({
  code: {
    type: String,
    required: [true, 'Vui lòng nhập mã giảm giá'],
    unique: true,
    uppercase: true,
    trim: true,
  },
  description: {
    type: String,
    required: [true, 'Vui lòng nhập mô tả'],
  },
  discountType: {
    type: String,
    enum: ['percentage', 'fixed'],
    default: 'percentage',
  },
  discountValue: {
    type: Number,
    required: [true, 'Vui lòng nhập giá trị giảm'],
    min: [0, 'Giá trị giảm không được âm'],
  },
  minOrderAmount: {
    type: Number,
    default: 0,
  },
  maxDiscountAmount: {
    type: Number,
    default: null,
  },
  usageLimit: {
    type: Number,
    default: null,
  },
  usedCount: {
    type: Number,
    default: 0,
  },
  usagePerUser: {
    type: Number,
    default: 1,
  },
  usedByUsers: [{
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    usedAt: { type: Date, default: Date.now },
  }],
  startDate: {
    type: Date,
    default: Date.now,
  },
  endDate: {
    type: Date,
    required: [true, 'Vui lòng nhập ngày hết hạn'],
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  applicableProducts: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
  }],
  applicableBrands: [{
    type: String,
  }],
}, {
  timestamps: true,
});

// Check if coupon is valid
couponSchema.methods.isValid = function(userId, orderAmount) {
  const now = new Date();
  
  if (!this.isActive) {
    return { valid: false, message: 'Mã giảm giá không còn hiệu lực' };
  }
  
  if (now < this.startDate) {
    return { valid: false, message: 'Mã giảm giá chưa có hiệu lực' };
  }
  
  if (now > this.endDate) {
    return { valid: false, message: 'Mã giảm giá đã hết hạn' };
  }
  
  if (this.usageLimit && this.usedCount >= this.usageLimit) {
    return { valid: false, message: 'Mã giảm giá đã hết lượt sử dụng' };
  }
  
  if (orderAmount < this.minOrderAmount) {
    return { 
      valid: false, 
      message: `Đơn hàng tối thiểu ${this.minOrderAmount.toLocaleString('vi-VN')}đ` 
    };
  }
  
  if (userId) {
    const userUsage = this.usedByUsers.filter(
      u => u.user.toString() === userId.toString()
    ).length;
    
    if (userUsage >= this.usagePerUser) {
      return { valid: false, message: 'Bạn đã sử dụng hết lượt cho mã này' };
    }
  }
  
  return { valid: true };
};

// Calculate discount amount
couponSchema.methods.calculateDiscount = function(orderAmount) {
  let discount = 0;
  
  if (this.discountType === 'percentage') {
    discount = (orderAmount * this.discountValue) / 100;
    if (this.maxDiscountAmount && discount > this.maxDiscountAmount) {
      discount = this.maxDiscountAmount;
    }
  } else {
    discount = this.discountValue;
  }
  
  return Math.min(discount, orderAmount);
};

module.exports = mongoose.model('Coupon', couponSchema);
