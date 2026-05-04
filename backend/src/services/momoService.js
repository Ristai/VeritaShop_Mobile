const crypto = require('crypto');

/**
 * MoMo Payment Service
 * Implements MoMo Payment Gateway API v2 (captureWallet)
 * Documentation: https://developers.momo.vn/v3/docs/payment/api/wallet/create
 */

const MOMO_CONFIG = {
  partnerCode: process.env.MOMO_PARTNER_CODE || '',
  accessKey: process.env.MOMO_ACCESS_KEY || '',
  secretKey: process.env.MOMO_SECRET_KEY || '',
  endpoint: process.env.MOMO_ENDPOINT || 'https://test-payment.momo.vn/v2/gateway/api',
  redirectUrl: process.env.MOMO_REDIRECT_URL || 'veritashop://momo-return',
  ipnUrl: process.env.MOMO_IPN_URL || '',
};

/**
 * Generate HMAC SHA256 signature
 * @param {string} rawSignature - Raw signature string
 * @returns {string} - HMAC SHA256 hash
 */
function generateSignature(rawSignature) {
  return crypto
    .createHmac('sha256', MOMO_CONFIG.secretKey)
    .update(rawSignature)
    .digest('hex');
}

/**
 * Generate unique request ID
 * @param {string} prefix - Prefix for the ID
 * @returns {string} - Unique ID
 */
function generateRequestId(prefix = 'VTS') {
  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 1000000).toString().padStart(6, '0');
  return `${prefix}${timestamp}${random}`;
}

/**
 * Create MoMo payment request
 * @param {Object} params - Payment parameters
 * @param {string} params.orderId - Internal order ID
 * @param {number} params.amount - Payment amount in VND
 * @param {string} params.orderInfo - Order description
 * @param {string} params.extraData - Extra data (base64 encoded JSON)
 * @returns {Promise<Object>} - MoMo API response
 */
async function createPayment({ orderId, amount, orderInfo, extraData = '' }) {
  // Validate config
  if (!MOMO_CONFIG.partnerCode || !MOMO_CONFIG.accessKey || !MOMO_CONFIG.secretKey) {
    throw new Error('MoMo configuration is incomplete. Please set MOMO_PARTNER_CODE, MOMO_ACCESS_KEY, and MOMO_SECRET_KEY environment variables.');
  }

  if (!MOMO_CONFIG.ipnUrl) {
    throw new Error('MOMO_IPN_URL is not configured.');
  }

  const requestId = generateRequestId();
  const momoOrderId = `MOMO_${orderId}_${Date.now()}`;
  const requestType = 'captureWallet';
  const lang = 'vi';

  // Build raw signature
  // accessKey=$accessKey&amount=$amount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType
  const rawSignature = [
    `accessKey=${MOMO_CONFIG.accessKey}`,
    `amount=${amount}`,
    `extraData=${extraData}`,
    `ipnUrl=${MOMO_CONFIG.ipnUrl}`,
    `orderId=${momoOrderId}`,
    `orderInfo=${orderInfo}`,
    `partnerCode=${MOMO_CONFIG.partnerCode}`,
    `redirectUrl=${MOMO_CONFIG.redirectUrl}`,
    `requestId=${requestId}`,
    `requestType=${requestType}`,
  ].join('&');

  const signature = generateSignature(rawSignature);

  const requestBody = {
    partnerCode: MOMO_CONFIG.partnerCode,
    accessKey: MOMO_CONFIG.accessKey,
    requestId,
    amount,
    orderId: momoOrderId,
    orderInfo,
    redirectUrl: MOMO_CONFIG.redirectUrl,
    ipnUrl: MOMO_CONFIG.ipnUrl,
    extraData,
    requestType,
    signature,
    lang,
  };

  console.log('MoMo Create Payment Request:', JSON.stringify(requestBody, null, 2));

  const response = await fetch(`${MOMO_CONFIG.endpoint}/create`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(requestBody),
  });

  const result = await response.json();
  console.log('MoMo Create Payment Response:', JSON.stringify(result, null, 2));

  return {
    ...result,
    requestId,
    momoOrderId,
  };
}

/**
 * Verify IPN signature from MoMo callback
 * @param {Object} ipnBody - IPN request body
 * @returns {boolean} - True if signature is valid
 */
function verifyIpnSignature(ipnBody) {
  const {
    accessKey,
    amount,
    extraData,
    message,
    orderId,
    orderInfo,
    orderType,
    partnerCode,
    payType,
    requestId,
    responseTime,
    resultCode,
    transId,
    signature,
  } = ipnBody;

  // Build raw signature for verification
  // accessKey=$accessKey&amount=$amount&extraData=$extraData&message=$message&orderId=$orderId&orderInfo=$orderInfo&orderType=$orderType&partnerCode=$partnerCode&payType=$payType&requestId=$requestId&responseTime=$responseTime&resultCode=$resultCode&transId=$transId
  const rawSignature = [
    `accessKey=${accessKey || MOMO_CONFIG.accessKey}`,
    `amount=${amount}`,
    `extraData=${extraData || ''}`,
    `message=${message}`,
    `orderId=${orderId}`,
    `orderInfo=${orderInfo}`,
    `orderType=${orderType}`,
    `partnerCode=${partnerCode}`,
    `payType=${payType}`,
    `requestId=${requestId}`,
    `responseTime=${responseTime}`,
    `resultCode=${resultCode}`,
    `transId=${transId}`,
  ].join('&');

  const expectedSignature = generateSignature(rawSignature);

  console.log('IPN Signature Verification:');
  console.log('Raw Signature:', rawSignature);
  console.log('Expected:', expectedSignature);
  console.log('Received:', signature);

  return expectedSignature === signature;
}

/**
 * Query transaction status from MoMo
 * @param {string} orderId - MoMo order ID
 * @param {string} requestId - Original request ID
 * @returns {Promise<Object>} - MoMo API response
 */
async function queryTransactionStatus(orderId, requestId) {
  // Validate config
  if (!MOMO_CONFIG.partnerCode || !MOMO_CONFIG.accessKey || !MOMO_CONFIG.secretKey) {
    throw new Error('MoMo configuration is incomplete.');
  }

  const queryRequestId = generateRequestId('QUERY');
  const lang = 'vi';

  // Build raw signature
  // accessKey=$accessKey&orderId=$orderId&partnerCode=$partnerCode&requestId=$requestId
  const rawSignature = [
    `accessKey=${MOMO_CONFIG.accessKey}`,
    `orderId=${orderId}`,
    `partnerCode=${MOMO_CONFIG.partnerCode}`,
    `requestId=${queryRequestId}`,
  ].join('&');

  const signature = generateSignature(rawSignature);

  const requestBody = {
    partnerCode: MOMO_CONFIG.partnerCode,
    requestId: queryRequestId,
    orderId,
    lang,
    signature,
  };

  console.log('MoMo Query Status Request:', JSON.stringify(requestBody, null, 2));

  const response = await fetch(`${MOMO_CONFIG.endpoint}/query`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(requestBody),
  });

  const result = await response.json();
  console.log('MoMo Query Status Response:', JSON.stringify(result, null, 2));

  return result;
}

/**
 * Parse MoMo result code to payment status
 * @param {number} resultCode - MoMo result code
 * @returns {string} - Payment status
 */
function parseResultCode(resultCode) {
  // MoMo result codes:
  // 0 - Success
  // 1000 - Transaction initiated, waiting for user confirmation
  // 1001 - Transaction failed
  // 1002 - Transaction rejected by user
  // 1003 - Transaction cancelled
  // 1004 - Transaction amount exceeded limit
  // 1005 - Transaction URL expired
  // 1006 - Transaction timed out
  // 7000 - Transaction is being processed
  // 7002 - Transaction is being processed by MoMo
  // 9000 - Transaction authorized successfully
  switch (resultCode) {
    case 0:
    case 9000:
      return 'success';
    case 1000:
    case 7000:
    case 7002:
      return 'processing';
    case 1005:
      return 'pending'; // URL expired but transaction may still be valid
    case 1002:
    case 1003:
    case 1006:
      return 'cancelled';
    default:
      return 'failed';
  }
}

module.exports = {
  createPayment,
  verifyIpnSignature,
  queryTransactionStatus,
  parseResultCode,
  generateRequestId,
  MOMO_CONFIG,
};
