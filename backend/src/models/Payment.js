const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  method: {
    type: String,
    enum: ['MoMo', 'VNPay', 'ZaloPay'],
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
  // MoMo specific fields
  requestId: {
    type: String,
    required: true,
    unique: true,
  },
  momoOrderId: {
    type: String,
    unique: true,
    sparse: true,
  },
  transId: {
    type: String,
    sparse: true,
  },
  payUrl: {
    type: String,
  },
  deeplink: {
    type: String,
  },
  qrCodeUrl: {
    type: String,
  },
  // Payment status
  status: {
    type: String,
    enum: ['pending', 'processing', 'success', 'failed', 'cancelled', 'refunded'],
    default: 'pending',
  },
  resultCode: {
    type: Number,
  },
  message: {
    type: String,
  },
  // Extra data for tracking
  orderInfo: {
    type: String,
  },
  extraData: {
    type: String,
  },
  // IPN data
  ipnReceivedAt: {
    type: Date,
  },
  ipnData: {
    type: mongoose.Schema.Types.Mixed,
  },
}, {
  timestamps: true,
});

// Indexes for better query performance
paymentSchema.index({ order: 1 });
paymentSchema.index({ momoOrderId: 1 });
paymentSchema.index({ requestId: 1 });
paymentSchema.index({ transId: 1 });
paymentSchema.index({ status: 1 });
paymentSchema.index({ user: 1, createdAt: -1 });

// Virtual for status text in Vietnamese
paymentSchema.virtual('statusText').get(function() {
  const statusMap = {
    pending: 'Chờ thanh toán',
    processing: 'Đang xử lý',
    success: 'Thành công',
    failed: 'Thất bại',
    cancelled: 'Đã hủy',
    refunded: 'Đã hoàn tiền',
  };
  return statusMap[this.status] || this.status;
});

paymentSchema.set('toJSON', { virtuals: true });
paymentSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Payment', paymentSchema);
