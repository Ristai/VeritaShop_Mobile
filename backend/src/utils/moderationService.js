/**
 * Content Moderation Service
 * Calls external API to moderate review content (text and/or images)
 */

const MODERATION_API_URL = 'https://api2.honeysocial.click/api/moderate';
const TIMEOUT_MS = 10000; // 10 seconds for image processing

// Moderation categories with Vietnamese translations
const MODERATION_CATEGORIES = {
  'harassment': 'Quấy rối',
  'harassment/threatening': 'Quấy rối/Đe dọa',
  'hate': 'Thù ghét',
  'hate/threatening': 'Thù ghét/Đe dọa',
  'illicit': 'Bất hợp pháp',
  'illicit/violent': 'Bất hợp pháp/Bạo lực',
  'self-harm': 'Tự gây hại',
  'self-harm/intent': 'Tự gây hại/Ý định',
  'self-harm/instructions': 'Tự gây hại/Hướng dẫn',
  'sexual': 'Nội dung người lớn',
  'sexual/minors': 'Nội dung trẻ em',
  'violence': 'Bạo lực',
  'violence/graphic': 'Bạo lực/Hình ảnh',
};

/**
 * Build request body based on input type
 * @param {string} text - Review text
 * @param {Array<string>} imageUrls - Array of image URLs
 * @returns {Object} Request body for moderation API
 */
const buildRequestBody = (text, imageUrls) => {
  const hasText = text && typeof text === 'string' && text.trim().length > 0;
  const hasImages = imageUrls && Array.isArray(imageUrls) && imageUrls.length > 0;

  // Text only
  if (hasText && !hasImages) {
    return { input: text.trim() };
  }

  // Image only
  if (!hasText && hasImages) {
    return {
      input: imageUrls.map(url => ({
        type: 'image_url',
        image_url: { url },
      })),
    };
  }

  // Combined text and images
  if (hasText && hasImages) {
    const input = [
      { type: 'text', text: text.trim() },
      ...imageUrls.map(url => ({
        type: 'image_url',
        image_url: { url },
      })),
    ];
    return { input };
  }

  // No content to moderate
  return null;
};

/**
 * Moderate content using external API
 * @param {string} text - Review text to moderate
 * @param {Array<string>} imageUrls - Array of image URLs to moderate
 * @returns {Promise<Object|null>} Moderation result or null on failure
 */
const moderateContent = async (text, imageUrls = []) => {
  const requestBody = buildRequestBody(text, imageUrls);

  if (!requestBody) {
    // No content to moderate, return clean result
    return {
      id: null,
      model: null,
      flagged: false,
      categories: {},
      categoryScores: {},
      checkedAt: new Date(),
    };
  }

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

    const response = await fetch(MODERATION_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      console.error(`Moderation API error: ${response.status} ${response.statusText}`);
      return null;
    }

    const data = await response.json();

    if (!data.success || !data.results || !Array.isArray(data.results) || data.results.length === 0) {
      console.error('Moderation API returned invalid response format');
      return null;
    }

    const result = data.results[0];

    return {
      id: data.id || null,
      model: data.model || null,
      flagged: result.flagged || false,
      categories: result.categories || {},
      categoryScores: result.category_scores || {},
      checkedAt: new Date(),
    };
  } catch (error) {
    if (error.name === 'AbortError') {
      console.error('Moderation API request timed out');
    } else {
      console.error('Moderation API request failed:', error.message);
    }
    return null;
  }
};

/**
 * Get flagged categories as Vietnamese strings
 * @param {Object} categories - Categories object from moderation result
 * @returns {Array<string>} Array of Vietnamese category names that are flagged
 */
const getFlaggedCategoriesVietnamese = (categories) => {
  if (!categories || typeof categories !== 'object') {
    return [];
  }

  return Object.entries(categories)
    .filter(([, isFlagged]) => isFlagged === true)
    .map(([category]) => MODERATION_CATEGORIES[category] || category);
};

/**
 * Check if content should be flagged based on moderation result
 * @param {Object} moderationResult - Result from moderateContent
 * @returns {boolean}
 */
const shouldFlag = (moderationResult) => {
  return moderationResult && moderationResult.flagged === true;
};

module.exports = {
  moderateContent,
  getFlaggedCategoriesVietnamese,
  shouldFlag,
  MODERATION_CATEGORIES,
};
