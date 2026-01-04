/**
 * File Search Export Service
 * Generates JSON documents for OpenAI Vector Store
 */

const { generateProductDocument, generateMetadataAttributes, generateAttributesSchema, getProductsForExport } = require('./documentGenerator');
const { aggregateSentiment, getAspectScores, SUPPORTED_ASPECTS, PRIMARY_ASPECTS } = require('./sentimentAggregator');
const { selectFeaturedReviews, getAllReviews } = require('./reviewSelector');
const { getApplicableCoupons } = require('./couponMatcher');
const { getPriceRange, getStockStatus, formatPrice, generateSearchableContent } = require('./contentFormatter');

module.exports = {
  // Main generator
  generateProductDocument,
  generateMetadataAttributes,
  generateAttributesSchema,
  getProductsForExport,

  // Sentiment
  aggregateSentiment,
  getAspectScores,
  SUPPORTED_ASPECTS,
  PRIMARY_ASPECTS,

  // Reviews
  selectFeaturedReviews,
  getAllReviews,

  // Coupons
  getApplicableCoupons,

  // Helpers
  getPriceRange,
  getStockStatus,
  formatPrice,
  generateSearchableContent
};
