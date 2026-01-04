/**
 * Document Generator for OpenAI File Search
 * Main service that generates complete JSON documents for products
 */

const Product = require('../../models/Product');
const { aggregateSentiment, getAspectScores } = require('./sentimentAggregator');
const { selectFeaturedReviews, getAllReviews } = require('./reviewSelector');
const { getApplicableCoupons } = require('./couponMatcher');
const { getPriceRange, getStockStatus, generateSearchableContent } = require('./contentFormatter');

/**
 * Format date to Vietnamese readable format
 * @param {Date} date - Date object
 * @returns {string} Formatted string like "15:30 ngày 05/01/2026"
 */
function formatVietnameseDateTime(date) {
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const year = date.getFullYear();

  return `${hours}:${minutes} ngày ${day}/${month}/${year}`;
}

/**
 * Generate a complete document for a single product
 * @param {ObjectId|string} productId - Product ID
 * @returns {Object} Complete document ready for export
 */
async function generateProductDocument(productId) {
  // Fetch product with all fields
  const product = await Product.findById(productId).lean();

  if (!product) {
    throw new Error(`Product not found: ${productId}`);
  }

  if (!product.isActive) {
    throw new Error(`Product is not active: ${productId}`);
  }

  // Aggregate sentiment data from reviews
  const sentimentSummary = await aggregateSentiment(product._id);

  // Get all reviews for the product
  const allReviews = await getAllReviews(product._id);

  // Featured reviews - commented out, using all_reviews instead
  // const featuredReviews = await selectFeaturedReviews(product._id);

  // Get applicable coupons
  const activeCoupons = await getApplicableCoupons(product._id, product.brand);

  // Calculate discount percentage
  let discountPercent = 0;
  if (product.originalPrice && product.originalPrice > product.price) {
    discountPercent = Math.round((1 - product.price / product.originalPrice) * 100);
  }

  // Get stock status
  const stockStatus = getStockStatus(product.stock);

  // Build the document structure
  const now = new Date();
  const document = {
    product_id: product._id.toString(),
    generated_at: now.toISOString(),
    data_updated_at: formatVietnameseDateTime(now),
    data_notice: `Thông tin sản phẩm được cập nhật đến ${formatVietnameseDateTime(now)}. Dữ liệu có thể đã thay đổi sau thời điểm này.`,

    product_info: {
      name: product.name,
      brand: product.brand,
      price: product.price,
      // original_price - commented out
      // original_price: product.originalPrice || product.price,
      // discount_percent - commented out
      // discount_percent: discountPercent,
      condition: product.condition,
      warranty: product.warranty,
      // stock - commented out
      // stock: product.stock,
      stock_status: stockStatus,
      rating: product.rating,
      review_count: product.reviewCount || 0,
      specs: product.specs ? {
        ram: product.specs.ram,
        rom: product.specs.rom,
        chip: product.specs.chip,
        battery: product.specs.battery,
        screen: product.specs.screen,
        camera: product.specs.camera
      } : null,
      colors: product.colors ? product.colors.map(c => c.name) : []
      // images - commented out
      // images: product.images || []
    },

    // All reviews from database
    all_reviews: allReviews,

    // Featured reviews - commented out, using all_reviews instead
    // featured_reviews: featuredReviews,

    active_coupons: activeCoupons

    // searchable_content - commented out
    // searchable_content: ''
  };

  // Store sentiment summary internally for metadata attributes (not in document)
  document._sentimentSummary = sentimentSummary;

  // Generate searchable content - commented out
  // document.searchable_content = generateSearchableContent(document);

  return document;
}

/**
 * Generate metadata attributes for a product document
 * These attributes are used for Vector Store filtering
 * @param {Object} document - Generated product document
 * @returns {Object} Metadata attributes
 */
function generateMetadataAttributes(document) {
  const { product_info, _sentimentSummary, active_coupons } = document;

  // Get aspect scores from internal sentiment summary
  const aspectScores = _sentimentSummary ? getAspectScores(_sentimentSummary) : {
    Battery_score: 50,
    Camera_score: 50,
    Performance_score: 50,
    Display_score: 50,
    Design_score: 50,
    Price_score: 50
  };

  return {
    product_id: document.product_id,
    brand: product_info.brand,
    price: product_info.price,
    price_range: getPriceRange(product_info.price),
    stock_status: product_info.stock_status,
    condition: product_info.condition,
    overall_rating: product_info.rating,
    review_count: product_info.review_count,
    has_active_coupon: active_coupons.length > 0,
    Battery_score: aspectScores.Battery_score,
    Camera_score: aspectScores.Camera_score,
    Performance_score: aspectScores.Performance_score,
    Display_score: aspectScores.Display_score,
    Design_score: aspectScores.Design_score,
    Price_score: aspectScores.Price_score
  };
}

/**
 * Generate the attributes schema for Vector Store configuration
 * @returns {Object} Attributes schema
 */
function generateAttributesSchema() {
  return {
    attributes: [
      { name: 'product_id', type: 'string' },
      { name: 'brand', type: 'string' },
      { name: 'price', type: 'number' },
      { name: 'price_range', type: 'string' },
      { name: 'stock_status', type: 'string' },
      { name: 'condition', type: 'string' },
      { name: 'overall_rating', type: 'number' },
      { name: 'review_count', type: 'number' },
      { name: 'has_active_coupon', type: 'boolean' },
      { name: 'Battery_score', type: 'number' },
      { name: 'Camera_score', type: 'number' },
      { name: 'Performance_score', type: 'number' },
      { name: 'Display_score', type: 'number' },
      { name: 'Design_score', type: 'number' },
      { name: 'Price_score', type: 'number' }
    ]
  };
}

/**
 * Get all active products for export
 * @param {Object} filters - Optional filters
 * @param {string} filters.brand - Filter by brand
 * @param {string} filters.condition - Filter by condition
 * @returns {Array} Array of product IDs
 */
async function getProductsForExport(filters = {}) {
  const query = { isActive: true };

  if (filters.brand) {
    query.brand = filters.brand;
  }

  if (filters.condition) {
    query.condition = filters.condition;
  }

  const products = await Product.find(query)
    .select('_id name brand')
    .lean();

  return products;
}

module.exports = {
  generateProductDocument,
  generateMetadataAttributes,
  generateAttributesSchema,
  getProductsForExport
};
