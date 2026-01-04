/**
 * Content Formatter for OpenAI File Search
 * Generates searchable_content text from product data
 */

/**
 * Price range categories (VNĐ)
 */
const PRICE_RANGES = [
  { max: 5000000, label: '0-5M' },
  { max: 10000000, label: '5-10M' },
  { max: 15000000, label: '10-15M' },
  { max: 20000000, label: '15-20M' },
  { max: 30000000, label: '20-30M' },
  { max: 50000000, label: '30-50M' },
  { max: Infinity, label: '50M+' }
];

/**
 * Get price range label from price
 * @param {number} price - Price in VNĐ
 * @returns {string} Price range label
 */
function getPriceRange(price) {
  for (const range of PRICE_RANGES) {
    if (price <= range.max) {
      return range.label;
    }
  }
  return '50M+';
}

/**
 * Get stock status from stock quantity
 * @param {number} stock - Stock quantity
 * @returns {string} Stock status
 */
function getStockStatus(stock) {
  if (stock === 0) return 'out_of_stock';
  if (stock < 10) return 'low_stock';
  return 'in_stock';
}

/**
 * Format price for display (VNĐ)
 * @param {number} price - Price in VNĐ
 * @returns {string} Formatted price
 */
function formatPrice(price) {
  return price.toLocaleString('vi-VN') + 'đ';
}

/**
 * Bilingual aspect name mapping
 */
const ASPECT_BILINGUAL = {
  Battery: 'Battery/Pin',
  Camera: 'Camera',
  Performance: 'Performance/Hiệu năng',
  Display: 'Display/Màn hình',
  Design: 'Design/Thiết kế',
  Price: 'Price/Giá',
  Packaging: 'Packaging/Đóng gói',
  Shop_Service: 'Shop_Service/Dịch vụ',
  Shipping: 'Shipping/Giao hàng',
  General: 'General/Tổng quan',
  Others: 'Others/Khác'
};

/**
 * Condition labels in Vietnamese
 */
const CONDITION_LABELS = {
  new: 'Mới 100%',
  likenew: 'Like New 99%',
  used: 'Đã sử dụng'
};

/**
 * Generate searchable content text from product document data
 * This text is optimized for semantic search by OpenAI File Search
 *
 * @param {Object} data - Document data object
 * @returns {string} Searchable content text
 */
function generateSearchableContent(data) {
  const { product_info, all_reviews, active_coupons } = data;

  const lines = [];

  // Product basic info
  lines.push(`${product_info.name} - Hãng ${product_info.brand} - Giá ${formatPrice(product_info.price)}`);

  // Discount info
  if (product_info.discount_percent > 0) {
    lines.push(`(giảm ${product_info.discount_percent}% từ ${formatPrice(product_info.original_price)})`);
  }

  // Condition and warranty
  lines.push(`Tình trạng: ${CONDITION_LABELS[product_info.condition] || product_info.condition}. Bảo hành: ${product_info.warranty}.`);

  // Stock status
  const stockText = product_info.stock_status === 'in_stock'
    ? `Còn hàng (${product_info.stock} sản phẩm)`
    : product_info.stock_status === 'low_stock'
      ? `Sắp hết hàng (${product_info.stock} sản phẩm)`
      : 'Hết hàng';
  lines.push(stockText);

  // Specs
  if (product_info.specs) {
    const specs = product_info.specs;
    lines.push(`Thông số kỹ thuật: Chip ${specs.chip}, RAM ${specs.ram}, Bộ nhớ ${specs.rom}, Màn hình ${specs.screen}, Camera ${specs.camera}, Pin ${specs.battery}.`);
  }

  // Colors
  if (product_info.colors && product_info.colors.length > 0) {
    lines.push(`Màu sắc: ${product_info.colors.join(', ')}.`);
  }

  // Rating summary
  lines.push('');
  lines.push(`ĐÁNH GIÁ TỔNG QUAN: ${product_info.rating}/5 sao từ ${product_info.review_count} đánh giá.`);

  // Reviews - use all_reviews instead of featured_reviews
  if (all_reviews && all_reviews.length > 0) {
    lines.push('');
    lines.push('NHẬN XÉT NỔI BẬT:');

    // Take top 5 reviews by rating
    const topReviews = all_reviews
      .sort((a, b) => b.rating - a.rating)
      .slice(0, 5);

    for (const review of topReviews) {
      const stars = '★'.repeat(review.rating);
      const truncatedText = review.text.length > 100
        ? review.text.substring(0, 100) + '...'
        : review.text;
      lines.push(`- '${truncatedText}' - ${review.user_name} ${stars}`);
    }
  }

  // Coupons
  if (active_coupons && active_coupons.length > 0) {
    lines.push('');
    lines.push('KHUYẾN MÃI ĐANG ÁP DỤNG:');

    for (const coupon of active_coupons) {
      let discountText = '';
      if (coupon.discount_type === 'percentage') {
        discountText = `Giảm ${coupon.discount_value}%`;
        if (coupon.max_discount) {
          discountText += ` tối đa ${formatPrice(coupon.max_discount)}`;
        }
      } else {
        discountText = `Giảm ${formatPrice(coupon.discount_value)}`;
      }

      let conditionText = '';
      if (coupon.min_order) {
        conditionText = ` đơn từ ${formatPrice(coupon.min_order)}`;
      }

      lines.push(`- Mã ${coupon.code}: ${discountText}${conditionText} - Hết hạn ${formatDateVi(coupon.end_date)}`);
    }
  }

  return lines.join('\n');
}

/**
 * Format date to Vietnamese format (DD/MM/YYYY)
 * @param {string} dateStr - Date string (YYYY-MM-DD)
 * @returns {string} Formatted date
 */
function formatDateVi(dateStr) {
  if (!dateStr) return '';
  const [year, month, day] = dateStr.split('-');
  return `${day}/${month}/${year}`;
}

module.exports = {
  getPriceRange,
  getStockStatus,
  formatPrice,
  generateSearchableContent,
  ASPECT_BILINGUAL,
  CONDITION_LABELS,
  PRICE_RANGES
};
