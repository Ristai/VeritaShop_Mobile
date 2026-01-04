/**
 * Sentiment Aggregator for OpenAI File Search
 * Aggregates ABSA sentiment analysis data from reviews by aspect
 */

const Review = require('../../models/Review');

// Aspects supported by the ABSA system
const SUPPORTED_ASPECTS = [
  'Battery', 'Camera', 'Performance', 'Display', 'Design',
  'Packaging', 'Price', 'Shop_Service', 'Shipping', 'General', 'Others'
];

// Primary aspects for Vector Store filtering (product-related)
const PRIMARY_ASPECTS = ['Battery', 'Camera', 'Performance', 'Display', 'Design', 'Price'];

/**
 * Aggregate sentiment data for a product from all its reviews
 * @param {ObjectId} productId - MongoDB ObjectId of the product
 * @returns {Object} Aggregated sentiment summary
 */
async function aggregateSentiment(productId) {
  // Get all active reviews with sentiment analysis for this product
  const reviews = await Review.find({
    product: productId,
    isActive: true,
    moderationStatus: 'approved'
  }).select('sentimentAnalysis overallSentiment rating text createdAt').lean();

  if (reviews.length === 0) {
    return {
      overall_sentiment: 'neutral',
      total_reviews: 0,
      aspects: {},
      insufficient_data: true
    };
  }

  // Initialize aspect counters
  const aspectData = {};
  SUPPORTED_ASPECTS.forEach(aspect => {
    aspectData[aspect] = {
      positive_count: 0,
      negative_count: 0,
      neutral_count: 0,
      total: 0,
      top_positive_text: null,
      top_positive_confidence: 0
    };
  });

  // Count overall sentiments
  let positiveCount = 0;
  let negativeCount = 0;
  let neutralCount = 0;
  let mixedCount = 0;

  // Process each review
  for (const review of reviews) {
    // Count overall sentiment
    switch (review.overallSentiment) {
      case 'positive': positiveCount++; break;
      case 'negative': negativeCount++; break;
      case 'neutral': neutralCount++; break;
      case 'mixed': mixedCount++; break;
    }

    // Process aspect-level sentiments
    if (review.sentimentAnalysis && Array.isArray(review.sentimentAnalysis)) {
      for (const analysis of review.sentimentAnalysis) {
        const { aspect, sentiment, confidence } = analysis;

        if (!aspectData[aspect]) continue;
        if (sentiment === 'none') continue;

        aspectData[aspect].total++;

        switch (sentiment) {
          case 'positive':
            aspectData[aspect].positive_count++;
            // Track top positive review text for summary
            if (confidence > aspectData[aspect].top_positive_confidence) {
              aspectData[aspect].top_positive_text = review.text;
              aspectData[aspect].top_positive_confidence = confidence;
            }
            break;
          case 'negative':
            aspectData[aspect].negative_count++;
            break;
          case 'neutral':
            aspectData[aspect].neutral_count++;
            break;
        }
      }
    }
  }

  // Determine overall sentiment (only positive, negative, or neutral - no mixed)
  // "mixed" reviews from DB are counted based on their aspect sentiments
  let overall_sentiment = 'neutral';

  // For mixed reviews, count them based on majority of their aspect sentiments
  // or treat as neutral if truly mixed
  const effectivePositive = positiveCount;
  const effectiveNegative = negativeCount;
  const effectiveNeutral = neutralCount + mixedCount; // treat mixed as neutral for overall

  const total = effectivePositive + effectiveNegative + effectiveNeutral;
  if (total > 0) {
    if (effectivePositive > effectiveNegative && effectivePositive >= effectiveNeutral) {
      overall_sentiment = 'positive';
    } else if (effectiveNegative > effectivePositive && effectiveNegative >= effectiveNeutral) {
      overall_sentiment = 'negative';
    } else {
      overall_sentiment = 'neutral';
    }
  }

  // Build final aspects object with scores and summaries
  const aspects = {};
  for (const [aspect, data] of Object.entries(aspectData)) {
    if (data.total === 0) continue;

    const score = Math.round((data.positive_count / data.total) * 100);

    // Generate summary from top positive review or generic message
    let summary = generateAspectSummary(aspect, data);

    aspects[aspect] = {
      positive_count: data.positive_count,
      negative_count: data.negative_count,
      neutral_count: data.neutral_count,
      total: data.total,
      score,
      summary
    };
  }

  return {
    overall_sentiment,
    total_reviews: reviews.length,
    aspects,
    insufficient_data: reviews.length < 5
  };
}

/**
 * Generate a summary text for an aspect based on sentiment data
 * @param {string} aspect - Aspect name
 * @param {Object} data - Aspect sentiment data
 * @returns {string} Summary text
 */
function generateAspectSummary(aspect, data) {
  // If we have a top positive review, extract a relevant snippet
  if (data.top_positive_text && data.positive_count > data.negative_count) {
    // Try to find aspect-related snippet (simplified - first 100 chars)
    const text = data.top_positive_text;
    if (text.length <= 80) {
      return text;
    }
    // Return first 80 chars + ellipsis
    return text.substring(0, 80).trim() + '...';
  }

  // Default summaries by aspect
  const defaultSummaries = {
    Battery: data.score >= 70 ? 'Pin tốt, sử dụng lâu' : 'Pin ở mức trung bình',
    Camera: data.score >= 70 ? 'Camera chụp đẹp' : 'Camera ở mức trung bình',
    Performance: data.score >= 70 ? 'Hiệu năng mạnh mẽ' : 'Hiệu năng ổn định',
    Display: data.score >= 70 ? 'Màn hình sắc nét' : 'Màn hình ở mức trung bình',
    Design: data.score >= 70 ? 'Thiết kế đẹp, sang trọng' : 'Thiết kế ở mức trung bình',
    Price: data.score >= 70 ? 'Giá hợp lý' : 'Giá khá cao',
    Packaging: data.score >= 70 ? 'Đóng gói cẩn thận' : 'Đóng gói ổn',
    Shop_Service: data.score >= 70 ? 'Dịch vụ tốt' : 'Dịch vụ cần cải thiện',
    Shipping: data.score >= 70 ? 'Giao hàng nhanh' : 'Giao hàng chậm',
    General: data.score >= 70 ? 'Sản phẩm tốt' : 'Sản phẩm tạm được',
    Others: data.score >= 70 ? 'Đánh giá tốt' : 'Đánh giá trung bình'
  };

  return defaultSummaries[aspect] || 'Chưa có đủ đánh giá';
}

/**
 * Calculate aspect scores for Vector Store filtering attributes
 * Returns only primary aspects with numeric scores (0-100)
 * @param {Object} sentimentSummary - Result from aggregateSentiment()
 * @returns {Object} Aspect scores object
 */
function getAspectScores(sentimentSummary) {
  const scores = {};

  for (const aspect of PRIMARY_ASPECTS) {
    const data = sentimentSummary.aspects[aspect];
    // Default to 50 (neutral) if no data
    scores[`${aspect}_score`] = data ? data.score : 50;
  }

  return scores;
}

module.exports = {
  aggregateSentiment,
  getAspectScores,
  SUPPORTED_ASPECTS,
  PRIMARY_ASPECTS
};
