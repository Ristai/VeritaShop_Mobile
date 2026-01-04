const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const {
  createMomoPayment,
  handleMomoIpn,
  checkMomoPaymentStatus,
  getPaymentByOrder,
} = require('../controllers/paymentController');

// MoMo Payment routes
// POST /api/payments/momo/create - Create MoMo payment (requires auth)
router.post('/momo/create', auth, createMomoPayment);

// POST /api/payments/momo/ipn - MoMo IPN callback (public, from MoMo servers)
router.post('/momo/ipn', handleMomoIpn);

// GET /api/payments/momo/status/:orderId - Check MoMo payment status (requires auth)
router.get('/momo/status/:orderId', auth, checkMomoPaymentStatus);

// GET /api/payments/:orderId - Get payment details by order ID (requires auth)
router.get('/:orderId', auth, getPaymentByOrder);

module.exports = router;
