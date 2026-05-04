/**
 * Coupon Matcher for OpenAI File Search
 * Matches applicable coupons for each product
 */

const Coupon = require('../../models/Coupon');

/**
 * Get active coupons applicable to a product
 * Matching criteria:
 * - Coupon is active (isActive = true)
 * - Current date is within startDate and endDate
 * - Product ID is in applicableProducts OR product brand is in applicableBrands OR no restrictions (universal)
 *
 * @param {ObjectId} productId - MongoDB ObjectId of the product
 * @param {string} productBrand - Brand of the product
 * @returns {Array} Array of applicable coupons
 */
async function getApplicableCoupons(productId, productBrand) {
  const now = new Date();

  // Query active coupons within date range
  const activeCoupons = await Coupon.find({
    isActive: true,
    startDate: { $lte: now },
    endDate: { $gte: now }
  }).lean();

  const applicable = [];

  for (const coupon of activeCoupons) {
    // Check if coupon applies to this product
    if (isCouponApplicable(coupon, productId, productBrand)) {
      applicable.push(formatCoupon(coupon));
    }
  }

  return applicable;
}

/**
 * Check if a coupon is applicable to a product
 * @param {Object} coupon - Coupon document
 * @param {ObjectId} productId - Product ID
 * @param {string} productBrand - Product brand
 * @returns {boolean} True if applicable
 */
function isCouponApplicable(coupon, productId, productBrand) {
  const hasProductRestriction = coupon.applicableProducts && coupon.applicableProducts.length > 0;
  const hasBrandRestriction = coupon.applicableBrands && coupon.applicableBrands.length > 0;

  // Universal coupon (no restrictions)
  if (!hasProductRestriction && !hasBrandRestriction) {
    return true;
  }

  // Check product-specific restriction
  if (hasProductRestriction) {
    const productIdStr = productId.toString();
    const isProductMatch = coupon.applicableProducts.some(
      p => p.toString() === productIdStr
    );
    if (isProductMatch) return true;
  }

  // Check brand-specific restriction
  if (hasBrandRestriction) {
    const isBrandMatch = coupon.applicableBrands.some(
      b => b.toLowerCase() === productBrand.toLowerCase()
    );
    if (isBrandMatch) return true;
  }

  return false;
}

/**
 * Format coupon for document export
 * @param {Object} coupon - Coupon document
 * @returns {Object} Formatted coupon
 */
function formatCoupon(coupon) {
  const formatted = {
    code: coupon.code,
    description: coupon.description,
    discount_type: coupon.discountType,
    discount_value: coupon.discountValue,
    end_date: formatDate(coupon.endDate)
  };

  // Add optional fields
  if (coupon.maxDiscountAmount) {
    formatted.max_discount = coupon.maxDiscountAmount;
  }

  if (coupon.minOrderAmount && coupon.minOrderAmount > 0) {
    formatted.min_order = coupon.minOrderAmount;
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
  getApplicableCoupons
};
