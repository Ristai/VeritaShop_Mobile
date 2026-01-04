const Review = require('../models/Review');
const Product = require('../models/Product');
const Order = require('../models/Order');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');
const { analyzeSentiment } = require('../utils/absaService');
const { moderateContent, shouldFlag } = require('../utils/moderationService');
const { createNotification } = require('./notificationController');

// @desc    Get reviews for a product
// @route   GET /api/reviews/product/:productId
const getProductReviews = async (req, res, next) => {
  try {
    const { productId } = req.params;
    const { page = 1, limit = 10, sort = 'newest', rating } = req.query;

    // Verify product exists
    const product = await Product.findById(productId);
    if (!product) {
      return errorResponse(res, 'Không tìm thấy sản phẩm', 404, 'PRODUCT_NOT_FOUND');
    }

    const query = { product: productId, isActive: true };
    
    // Filter by rating
    if (rating) {
      query.rating = parseInt(rating);
    }

    // Sort options
    let sortOption = {};
    switch (sort) {
      case 'highest':
        sortOption = { rating: -1, createdAt: -1 };
        break;
      case 'lowest':
        sortOption = { rating: 1, createdAt: -1 };
        break;
      case 'helpful':
        sortOption = { likes: -1, createdAt: -1 };
        break;
      case 'newest':
      default:
        sortOption = { createdAt: -1 };
        break;
    }

    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    const [reviews, total] = await Promise.all([
      Review.find(query)
        .populate('user', 'name avatar')
        .sort(sortOption)
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Review.countDocuments(query),
    ]);

    // Get rating distribution
    const ratingStats = await Review.aggregate([
      { $match: { product: product._id, isActive: true } },
      { $group: { _id: '$rating', count: { $sum: 1 } } },
      { $sort: { _id: -1 } },
    ]);

    const ratingDistribution = {
      5: 0, 4: 0, 3: 0, 2: 0, 1: 0,
    };
    ratingStats.forEach(stat => {
      ratingDistribution[stat._id] = stat.count;
    });

    const totalPages = Math.ceil(total / limitNum);

    return paginatedResponse(res, {
      reviews,
      summary: {
        averageRating: product.rating,
        totalReviews: product.reviewCount,
        ratingDistribution,
      },
    }, {
      page: pageNum,
      limit: limitNum,
      total,
      totalPages,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create a review
// @route   POST /api/reviews
const createReview = async (req, res, next) => {
  try {
    const { productId, rating, title, text, images } = req.body;

    // Verify product exists
    const product = await Product.findById(productId);
    if (!product) {
      return errorResponse(res, 'Không tìm thấy sản phẩm', 404, 'PRODUCT_NOT_FOUND');
    }

    // Check if user already reviewed this product
    // TEMPORARILY DISABLED FOR TESTING - Allow multiple reviews
    // const existingReview = await Review.findOne({
    //   user: req.user._id,
    //   product: productId,
    // });

    // if (existingReview) {
    //   return errorResponse(res, 'Bạn đã đánh giá sản phẩm này rồi', 400, 'ALREADY_REVIEWED');
    // }

    // Check if user has purchased this product (verified purchase)
    const hasPurchased = await Order.findOne({
      user: req.user._id,
      'items.product': productId,
      status: 'delivered',
    });

    // Analyze sentiment using ABSA API (non-blocking)
    let sentimentData = { sentimentAnalysis: [], overallSentiment: 'neutral' };
    try {
      const analysisResult = await analyzeSentiment(text);
      if (analysisResult) {
        sentimentData = analysisResult;
      }
    } catch (sentimentError) {
      console.error('Sentiment analysis failed:', sentimentError.message);
      // Continue without sentiment - graceful degradation
    }

    // Moderate content using external API (non-blocking)
    let moderationData = {
      isFlagged: false,
      moderationStatus: 'approved',
      moderationResult: null,
    };
    try {
      const moderationResult = await moderateContent(text, images || []);
      if (moderationResult) {
        const isFlagged = shouldFlag(moderationResult);
        moderationData = {
          isFlagged,
          moderationStatus: isFlagged ? 'pending' : 'approved',
          moderationResult,
        };
      }
    } catch (moderationError) {
      console.error('Content moderation failed:', moderationError.message);
      // Continue without moderation - graceful degradation
      // Set to pending so admin can review manually
      moderationData.moderationStatus = 'pending';
    }

    // Create review with sentiment data and moderation results
    const review = await Review.create({
      user: req.user._id,
      product: productId,
      rating,
      title,
      text,
      images: images || [],
      isVerifiedPurchase: !!hasPurchased,
      sentimentAnalysis: sentimentData.sentimentAnalysis,
      overallSentiment: sentimentData.overallSentiment,
      isFlagged: moderationData.isFlagged,
      moderationStatus: moderationData.moderationStatus,
      moderationResult: moderationData.moderationResult,
    });

    // Send notification if review was flagged
    if (moderationData.isFlagged) {
      createNotification({
        userId: req.user._id,
        type: 'system',
        title: 'Đánh giá đang chờ duyệt',
        message: `Đánh giá của bạn cho ${product.name} được phát hiện có nội dung không phù hợp và đang chờ kiểm duyệt.`,
        data: { reviewId: review._id.toString(), productId: productId },
      }).catch(err => {
        console.error('Failed to create review flagged notification:', err);
      });
    }

    // Populate user info
    await review.populate('user', 'name avatar');

    return successResponse(res, review, 'Đánh giá thành công', 201);
  } catch (error) {
    next(error);
  }
};

// @desc    Update a review
// @route   PUT /api/reviews/:id
const updateReview = async (req, res, next) => {
  try {
    const { rating, title, text, images } = req.body;

    const review = await Review.findOne({
      _id: req.params.id,
      user: req.user._id,
    }).populate('product', 'name');

    if (!review) {
      return errorResponse(res, 'Không tìm thấy đánh giá', 404, 'REVIEW_NOT_FOUND');
    }

    // Store previous moderation status to detect transition
    const previousModerationStatus = review.moderationStatus;

    // Check if content changed (text or images)
    const contentChanged = (text && text !== review.text) ||
                          (images && JSON.stringify(images) !== JSON.stringify(review.images));

    // Update fields
    if (rating) review.rating = rating;
    if (title !== undefined) review.title = title;
    if (text) review.text = text;
    if (images) review.images = images;

    // Re-moderate if content changed
    if (contentChanged) {
      try {
        const newText = text || review.text;
        const newImages = images || review.images;
        const moderationResult = await moderateContent(newText, newImages);
        if (moderationResult) {
          const isFlagged = shouldFlag(moderationResult);
          review.isFlagged = isFlagged;
          review.moderationStatus = isFlagged ? 'pending' : 'approved';
          review.moderationResult = moderationResult;
          review.moderationNote = null; // Clear previous admin note

          // Send notification if review was flagged after re-moderation (approved -> pending)
          if (isFlagged && previousModerationStatus === 'approved') {
            const productName = review.product?.name || 'sản phẩm';
            createNotification({
              userId: req.user._id,
              type: 'system',
              title: 'Đánh giá đang chờ duyệt',
              message: `Đánh giá của bạn cho ${productName} được phát hiện có nội dung không phù hợp và đang chờ kiểm duyệt.`,
              data: { reviewId: review._id.toString(), productId: review.product?._id?.toString() },
            }).catch(err => {
              console.error('Failed to create review re-flagged notification:', err);
            });
          }
        }
      } catch (moderationError) {
        console.error('Re-moderation failed:', moderationError.message);
        // Set to pending so admin can review manually
        review.moderationStatus = 'pending';
      }
    }

    await review.save();
    await review.populate('user', 'name avatar');

    return successResponse(res, review, 'Cập nhật đánh giá thành công');
  } catch (error) {
    next(error);
  }
};

// @desc    Delete a review
// @route   DELETE /api/reviews/:id
const deleteReview = async (req, res, next) => {
  try {
    const review = await Review.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!review) {
      return errorResponse(res, 'Không tìm thấy đánh giá', 404, 'REVIEW_NOT_FOUND');
    }

    return successResponse(res, null, 'Đã xóa đánh giá');
  } catch (error) {
    next(error);
  }
};

// @desc    Like a review
// @route   POST /api/reviews/:id/like
const likeReview = async (req, res, next) => {
  try {
    const review = await Review.findByIdAndUpdate(
      req.params.id,
      { $inc: { likes: 1 } },
      { new: true }
    );

    if (!review) {
      return errorResponse(res, 'Không tìm thấy đánh giá', 404, 'REVIEW_NOT_FOUND');
    }

    return successResponse(res, { likes: review.likes }, 'Đã thích đánh giá');
  } catch (error) {
    next(error);
  }
};

// @desc    Get user's reviews
// @route   GET /api/reviews/my-reviews
const getMyReviews = async (req, res, next) => {
  try {
    const { page = 1, limit = 10 } = req.query;

    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    const [reviews, total] = await Promise.all([
      Review.find({ user: req.user._id })
        .populate('product', 'name brand images price')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Review.countDocuments({ user: req.user._id }),
    ]);

    const totalPages = Math.ceil(total / limitNum);

    return paginatedResponse(res, reviews, {
      page: pageNum,
      limit: limitNum,
      total,
      totalPages,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProductReviews,
  createReview,
  updateReview,
  deleteReview,
  likeReview,
  getMyReviews,
};
