const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  type: {
    type: String,
    enum: ['order', 'promo', 'system'],
    required: true,
  },
  title: {
    type: String,
    required: [true, 'Tiêu đề thông báo là bắt buộc'],
    maxlength: 200,
  },
  message: {
    type: String,
    required: [true, 'Nội dung thông báo là bắt buộc'],
    maxlength: 500,
  },
  data: {
    type: mongoose.Schema.Types.Mixed,
    default: null,
  },
  isRead: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

// Indexes for better query performance
notificationSchema.index({ user: 1, createdAt: -1 });
notificationSchema.index({ user: 1, isRead: 1 });
notificationSchema.index({ type: 1 });

// TTL index to auto-delete notifications older than 30 days
notificationSchema.index({ createdAt: 1 }, { expireAfterSeconds: 30 * 24 * 60 * 60 });

// Virtual for formatted timestamp
notificationSchema.virtual('timestamp').get(function() {
  return this.createdAt;
});

notificationSchema.set('toJSON', { virtuals: true });
notificationSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Notification', notificationSchema);
