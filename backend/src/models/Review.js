const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true,
  },
  rating: {
    type: Number,
    required: [true, 'Vui lòng đánh giá sản phẩm'],
    min: [1, 'Đánh giá tối thiểu 1 sao'],
    max: [5, 'Đánh giá tối đa 5 sao'],
  },
  title: {
    type: String,
    trim: true,
    maxlength: [100, 'Tiêu đề không quá 100 ký tự'],
  },
  text: {
    type: String,
    required: [true, 'Vui lòng nhập nội dung đánh giá'],
    trim: true,
    maxlength: [2000, 'Nội dung không quá 2000 ký tự'],
  },
  images: [{
    type: String,
  }],
  isVerifiedPurchase: {
    type: Boolean,
    default: false,
  },
  likes: {
    type: Number,
    default: 0,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  // ABSA Sentiment Analysis fields
  sentimentAnalysis: [{
    aspect: {
      type: String,
      enum: ['Battery', 'Camera', 'Performance', 'Display', 'Design',
             'Packaging', 'Price', 'Shop_Service', 'Shipping', 'General'],
    },
    sentiment: {
      type: String,
      enum: ['positive', 'negative', 'neutral'],
    },
    confidence: {
      type: Number,
      default: 0,
    },
    scores: {
      positive: { type: Number, default: 0 },
      negative: { type: Number, default: 0 },
      neutral: { type: Number, default: 0 },
    },
  }],
  overallSentiment: {
    type: String,
    enum: ['positive', 'negative', 'neutral', 'mixed'],
    default: 'neutral',
  },
}, {
  timestamps: true,
});

// Compound index: one review per user per product
// TEMPORARILY DISABLED FOR TESTING - Allow multiple reviews
// reviewSchema.index({ user: 1, product: 1 }, { unique: true });
reviewSchema.index({ user: 1, product: 1 }); // Non-unique index for queries
reviewSchema.index({ product: 1, createdAt: -1 });
reviewSchema.index({ rating: 1 });

// Static method to calculate average rating for a product
reviewSchema.statics.calcAverageRating = async function(productId) {
  const stats = await this.aggregate([
    { $match: { product: productId, isActive: true } },
    {
      $group: {
        _id: '$product',
        avgRating: { $avg: '$rating' },
        count: { $sum: 1 },
      },
    },
  ]);

  const Product = mongoose.model('Product');
  
  if (stats.length > 0) {
    await Product.findByIdAndUpdate(productId, {
      rating: Math.round(stats[0].avgRating * 10) / 10,
      reviewCount: stats[0].count,
    });
  } else {
    await Product.findByIdAndUpdate(productId, {
      rating: 0,
      reviewCount: 0,
    });
  }
};

// Update product rating after save
reviewSchema.post('save', async function() {
  await this.constructor.calcAverageRating(this.product);
});

// Update product rating after remove
reviewSchema.post('findOneAndDelete', async function(doc) {
  if (doc) {
    await doc.constructor.calcAverageRating(doc.product);
  }
});

module.exports = mongoose.model('Review', reviewSchema);
