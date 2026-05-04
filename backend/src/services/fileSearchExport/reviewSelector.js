/**
 * Review Selector for OpenAI File Search
 * Selects reviews for each product document
 */

const Review = require('../../models/Review');

/**
 * Get all reviews for a product
 * Returns all active, approved reviews sorted by rating and date
 *
 * @param {ObjectId} productId - MongoDB ObjectId of the product
 * @param {Object} options - Selection options
 * @param {number} options.limit - Maximum reviews to return (default: 50)
 * @returns {Array} Array of all reviews
 */
async function getAllReviews(productId, options = {}) {
  const { limit = 50 } = options;

  // Get all active, approved reviews with user info
  const reviews = await Review.find({
    product: productId,
    isActive: true,
    moderationStatus: 'approved'
  })
    .populate('user', 'name')
    .sort({ rating: -1, createdAt: -1 })
    .limit(limit)
    .lean();

  return reviews.map(review => formatReview(review));
}

/**
 * Select featured reviews for a product (subset of best reviews)
 * Selection criteria:
 * - Top 3 overall reviews (highest rating, recent)
 * - Top 2 per primary aspect (positive sentiment)
 * - 1 constructive negative review
 *
 * @param {ObjectId} productId - MongoDB ObjectId of the product
 * @param {Object} options - Selection options
 * @param {number} options.maxTotal - Maximum total featured reviews (default: 15)
 * @returns {Array} Array of featured reviews
 */
async function selectFeaturedReviews(productId, options = {}) {
  const { maxTotal = 15 } = options;

  // Get all active, approved reviews with user info
  const reviews = await Review.find({
    product: productId,
    isActive: true,
    moderationStatus: 'approved'
  })
    .populate('user', 'name')
    .sort({ rating: -1, createdAt: -1 })
    .lean();

  if (reviews.length === 0) {
    return [];
  }

  const featured = [];
  const usedReviewIds = new Set();

  // 1. Select top 3 overall reviews (highest rating, any length)
  const topOverall = reviews
    .filter(r => r.rating >= 4 && r.text)
    .slice(0, 3);

  for (const review of topOverall) {
    if (featured.length >= maxTotal) break;
    featured.push(formatFeaturedReview(review, 'overall_best'));
    usedReviewIds.add(review._id.toString());
  }

  // If not enough high-rating reviews, add any reviews
  if (featured.length < 3) {
    const remaining = 3 - featured.length;
    const otherReviews = reviews
      .filter(r => r.text && !usedReviewIds.has(r._id.toString()))
      .slice(0, remaining);

    for (const review of otherReviews) {
      if (featured.length >= maxTotal) break;
      featured.push(formatFeaturedReview(review, 'overall_best'));
      usedReviewIds.add(review._id.toString());
    }
  }

  // 2. Select top 2 per primary aspect (any sentiment with aspect mentioned)
  const primaryAspects = ['Battery', 'Camera', 'Performance', 'Display', 'Design', 'Price'];

  for (const aspect of primaryAspects) {
    if (featured.length >= maxTotal) break;

    const aspectReviews = reviews
      .filter(r => {
        if (usedReviewIds.has(r._id.toString())) return false;
        if (!r.sentimentAnalysis) return false;

        // Check if review mentions this aspect (any sentiment)
        return r.sentimentAnalysis.some(
          sa => sa.aspect === aspect && sa.sentiment !== 'none'
        );
      })
      .slice(0, 2);

    for (const review of aspectReviews) {
      if (featured.length >= maxTotal) break;
      featured.push(formatFeaturedReview(review, 'aspect_top', aspect));
      usedReviewIds.add(review._id.toString());
    }
  }

  // 3. Select negative reviews (rating <= 3)
  const negativeReviews = reviews
    .filter(r => {
      if (usedReviewIds.has(r._id.toString())) return false;
      return r.rating <= 3 && r.text;
    })
    .slice(0, 2);

  for (const review of negativeReviews) {
    if (featured.length >= maxTotal) break;

    let negativeAspect = 'General';
    if (review.sentimentAnalysis) {
      const negativeAnalysis = review.sentimentAnalysis.find(
        sa => sa.sentiment === 'negative'
      );
      if (negativeAnalysis) {
        negativeAspect = negativeAnalysis.aspect;
      }
    }
    featured.push(formatFeaturedReview(review, 'constructive_negative', negativeAspect));
    usedReviewIds.add(review._id.toString());
  }

  // 4. Fill remaining slots with any unused reviews
  if (featured.length < maxTotal) {
    const remainingReviews = reviews
      .filter(r => !usedReviewIds.has(r._id.toString()) && r.text)
      .slice(0, maxTotal - featured.length);

    for (const review of remainingReviews) {
      featured.push(formatFeaturedReview(review, 'other'));
      usedReviewIds.add(review._id.toString());
    }
  }

  return featured;
}

/**
 * Normalize sentiment to only 3 values: positive, negative, neutral
 * @param {string} sentiment - Original sentiment value
 * @returns {string} Normalized sentiment
 */
function normalizeSentiment(sentiment) {
  if (sentiment === 'positive') return 'positive';
  if (sentiment === 'negative') return 'negative';
  // 'mixed', 'neutral', or any other value becomes 'neutral'
  return 'neutral';
}

/**
 * Format a review into the standard structure
 * @param {Object} review - Review document
 * @returns {Object} Formatted review
 */
function formatReview(review) {
  const aspects_mentioned = [];
  // Format sentiment_analysis without scores
  const sentiment_analysis = [];

  if (review.sentimentAnalysis && Array.isArray(review.sentimentAnalysis)) {
    for (const sa of review.sentimentAnalysis) {
      if (sa.sentiment !== 'none' && !aspects_mentioned.includes(sa.aspect)) {
        aspects_mentioned.push(sa.aspect);
      }
      // Only include aspect, sentiment - exclude scores and confidence
      sentiment_analysis.push({
        aspect: sa.aspect,
        sentiment: sa.sentiment
        // confidence - commented out
        // confidence: sa.confidence
        // scores: sa.scores // không cần scores
      });
    }
  }

  return {
    review_id: review._id.toString(),
    user_name: review.user?.name || 'Khách hàng',
    rating: review.rating,
    title: review.title || null,
    text: review.text,
    sentiment: normalizeSentiment(review.overallSentiment),
    aspects_mentioned,
    sentiment_analysis,
    created_at: formatDate(review.createdAt),
    is_verified_purchase: review.isVerifiedPurchase || false,
    likes: review.likes || 0
  };
}

/**
 * Format a review into the featured review structure
 * @param {Object} review - Review document
 * @param {string} type - Type of featured review
 * @param {string} aspect - Aspect name (for aspect_top and constructive_negative)
 * @returns {Object} Formatted featured review
 */
function formatFeaturedReview(review, type, aspect = null) {
  // Extract aspects mentioned from sentiment analysis
  const aspects_mentioned = [];
  if (review.sentimentAnalysis && Array.isArray(review.sentimentAnalysis)) {
    for (const sa of review.sentimentAnalysis) {
      if (sa.sentiment !== 'none' && !aspects_mentioned.includes(sa.aspect)) {
        aspects_mentioned.push(sa.aspect);
      }
    }
  }

  const formatted = {
    type,
    user_name: review.user?.name || 'Khách hàng',
    rating: review.rating,
    sentiment: normalizeSentiment(review.overallSentiment),
    text: review.text,
    aspects_mentioned,
    created_at: formatDate(review.createdAt),
    is_verified_purchase: review.isVerifiedPurchase || false
  };

  // Add aspect field for aspect-specific reviews
  if (aspect && (type === 'aspect_top' || type === 'constructive_negative')) {
    formatted.aspect = aspect;
  }

  return formatted;
}

/**
 * Format date to YYYY-MM-DD string
 * @param {Date} date - Date object
 * @returns {string} Formatted date string
 */
function formatDate(date) {
  if (!date) return null;
  const d = new Date(date);
  return d.toISOString().split('T')[0];
}

module.exports = {
  selectFeaturedReviews,
  getAllReviews
};
