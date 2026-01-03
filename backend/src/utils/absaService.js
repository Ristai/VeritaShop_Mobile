/**
 * ABSA (Aspect-Based Sentiment Analysis) Service
 * Calls external API to analyze sentiment for product reviews
 */

const ABSA_API_URL = 'https://api.honeysocial.click/predict';
const TIMEOUT_MS = 5000;

// Valid aspects from the ABSA API
const VALID_ASPECTS = [
  'Battery', 'Camera', 'Performance', 'Display', 'Design',
  'Packaging', 'Price', 'Shop_Service', 'Shipping', 'General'
];

/**
 * Analyze sentiment of review text using ABSA API
 * @param {string} text - Review text to analyze
 * @returns {Promise<{sentimentAnalysis: Array, overallSentiment: string}|null>}
 */
const analyzeSentiment = async (text) => {
  if (!text || typeof text !== 'string' || text.trim().length === 0) {
    return null;
  }

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

    const response = await fetch(ABSA_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text: text.trim() }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      console.error(`ABSA API error: ${response.status} ${response.statusText}`);
      return null;
    }

    const data = await response.json();

    if (!data.results || !Array.isArray(data.results)) {
      console.error('ABSA API returned invalid response format');
      return null;
    }

    // Process and validate results
    const sentimentAnalysis = data.results
      .filter(item => VALID_ASPECTS.includes(item.aspect))
      .map(item => ({
        aspect: item.aspect,
        sentiment: item.sentiment, // positive, negative, neutral
        confidence: item.confidence || 0,
        scores: {
          positive: item.scores?.positive || 0,
          negative: item.scores?.negative || 0,
          neutral: item.scores?.neutral || 0,
        },
      }));

    // Calculate overall sentiment
    const overallSentiment = calculateOverallSentiment(sentimentAnalysis);

    return {
      sentimentAnalysis,
      overallSentiment,
    };
  } catch (error) {
    if (error.name === 'AbortError') {
      console.error('ABSA API request timed out');
    } else {
      console.error('ABSA API request failed:', error.message);
    }
    return null;
  }
};

/**
 * Calculate overall sentiment from individual aspect sentiments
 * @param {Array} sentimentAnalysis - Array of aspect sentiment results
 * @returns {string} - 'positive', 'negative', 'neutral', or 'mixed'
 */
const calculateOverallSentiment = (sentimentAnalysis) => {
  if (!sentimentAnalysis || sentimentAnalysis.length === 0) {
    return 'neutral';
  }

  const sentimentCounts = {
    positive: 0,
    negative: 0,
    neutral: 0,
  };

  sentimentAnalysis.forEach(item => {
    if (sentimentCounts.hasOwnProperty(item.sentiment)) {
      sentimentCounts[item.sentiment]++;
    }
  });

  const total = sentimentAnalysis.length;

  // If more than 60% are positive
  if (sentimentCounts.positive / total >= 0.6) {
    return 'positive';
  }
  // If more than 60% are negative
  if (sentimentCounts.negative / total >= 0.6) {
    return 'negative';
  }
  // If has both positive and negative
  if (sentimentCounts.positive > 0 && sentimentCounts.negative > 0) {
    return 'mixed';
  }

  return 'neutral';
};

module.exports = {
  analyzeSentiment,
  VALID_ASPECTS,
};
