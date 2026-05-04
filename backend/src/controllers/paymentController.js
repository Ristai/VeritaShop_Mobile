const Payment = require('../models/Payment');
const Order = require('../models/Order');
const momoService = require('../services/momoService');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @desc    Create MoMo payment for an order
 * @route   POST /api/payments/momo/create
 * @access  Private
 */
const createMomoPayment = async (req, res, next) => {
  try {
    const { orderId } = req.body;

    if (!orderId) {
      return errorResponse(res, 'Vui lòng cung cấp orderId', 400, 'MISSING_ORDER_ID');
    }

    // Find the order and validate ownership
    const order = await Order.findOne({
      _id: orderId,
      user: req.user._id,
    });

    if (!order) {
      return errorResponse(res, 'Không tìm thấy đơn hàng', 404, 'ORDER_NOT_FOUND');
    }

    // Check if order is already paid
    if (order.paymentStatus === 'paid') {
      return errorResponse(res, 'Đơn hàng đã được thanh toán', 400, 'ORDER_ALREADY_PAID');
    }

    // Check if order is cancelled
    if (order.status === 'cancelled') {
      return errorResponse(res, 'Không thể thanh toán đơn hàng đã hủy', 400, 'ORDER_CANCELLED');
    }

    // Check for existing pending payment
    const existingPayment = await Payment.findOne({
      order: orderId,
      status: { $in: ['pending', 'processing'] },
    });

    if (existingPayment) {
      // Return existing payment URL if still valid (created within 15 minutes)
      const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000);
      if (existingPayment.createdAt > fifteenMinutesAgo) {
        return successResponse(res, {
          payment: {
            id: existingPayment._id,
            requestId: existingPayment.requestId,
            momoOrderId: existingPayment.momoOrderId,
            payUrl: existingPayment.payUrl,
            deeplink: existingPayment.deeplink,
            qrCodeUrl: existingPayment.qrCodeUrl,
            amount: existingPayment.amount,
            status: existingPayment.status,
          },
        }, 'Thanh toán đang chờ xử lý');
      }
      // Mark old payment as cancelled
      existingPayment.status = 'cancelled';
      existingPayment.message = 'Payment expired';
      await existingPayment.save();
    }

    // Create payment with MoMo
    const orderInfo = `Thanh toán đơn hàng ${order.orderNumber}`;
    const extraData = Buffer.from(JSON.stringify({
      orderId: order._id.toString(),
      orderNumber: order.orderNumber,
    })).toString('base64');

    const momoResult = await momoService.createPayment({
      orderId: order._id.toString(),
      amount: order.total,
      orderInfo,
      extraData,
    });

    // Check MoMo response
    if (momoResult.resultCode !== 0) {
      return errorResponse(
        res,
        momoResult.message || 'Không thể tạo thanh toán MoMo',
        400,
        'MOMO_CREATE_FAILED',
        { resultCode: momoResult.resultCode }
      );
    }

    // Save payment record
    const payment = await Payment.create({
      order: order._id,
      user: req.user._id,
      method: 'MoMo',
      amount: order.total,
      requestId: momoResult.requestId,
      momoOrderId: momoResult.momoOrderId,
      payUrl: momoResult.payUrl,
      deeplink: momoResult.deeplink,
      qrCodeUrl: momoResult.qrCodeUrl,
      orderInfo,
      extraData,
      status: 'pending',
    });

    // Update order payment reference
    order.payment = payment._id;
    order.paymentStatus = 'pending';
    await order.save();

    return successResponse(res, {
      payment: {
        id: payment._id,
        requestId: payment.requestId,
        momoOrderId: payment.momoOrderId,
        payUrl: payment.payUrl,
        deeplink: payment.deeplink,
        qrCodeUrl: payment.qrCodeUrl,
        amount: payment.amount,
        status: payment.status,
      },
    }, 'Tạo thanh toán MoMo thành công', 201);
  } catch (error) {
    console.error('Create MoMo payment error:', error);
    next(error);
  }
};

/**
 * @desc    Handle MoMo IPN callback
 * @route   POST /api/payments/momo/ipn
 * @access  Public (from MoMo servers)
 */
const handleMomoIpn = async (req, res, next) => {
  try {
    console.log('MoMo IPN received:', JSON.stringify(req.body, null, 2));

    const { orderId, resultCode, transId, amount, message } = req.body;

    // Verify signature
    const isValidSignature = momoService.verifyIpnSignature(req.body);
    if (!isValidSignature) {
      console.error('Invalid IPN signature');
      return res.status(400).json({ message: 'Invalid signature' });
    }

    // Find payment by MoMo order ID
    const payment = await Payment.findOne({ momoOrderId: orderId });
    if (!payment) {
      console.error('Payment not found for orderId:', orderId);
      return res.status(404).json({ message: 'Payment not found' });
    }

    // Parse status from result code
    const status = momoService.parseResultCode(resultCode);

    // Update payment record
    payment.status = status;
    payment.resultCode = resultCode;
    payment.message = message;
    payment.transId = transId;
    payment.ipnReceivedAt = new Date();
    payment.ipnData = req.body;
    await payment.save();

    // Update order status
    const order = await Order.findById(payment.order);
    if (order) {
      if (status === 'success') {
        order.paymentStatus = 'paid';
        // Confirm order after successful payment
        if (order.status === 'pending') {
          order.status = 'confirmed';
          order.confirmedAt = new Date();
        }
      } else if (status === 'failed' || status === 'cancelled') {
        order.paymentStatus = 'failed';
      }
      await order.save();
    }

    // Return 204 No Content to MoMo (as per documentation)
    return res.status(204).send();
  } catch (error) {
    console.error('MoMo IPN handling error:', error);
    // Still return 204 to acknowledge receipt
    return res.status(204).send();
  }
};

/**
 * @desc    Check MoMo payment status
 * @route   GET /api/payments/momo/status/:orderId
 * @access  Private
 */
const checkMomoPaymentStatus = async (req, res, next) => {
  try {
    const { orderId } = req.params;

    // Find the order and validate ownership
    const order = await Order.findOne({
      _id: orderId,
      user: req.user._id,
    });

    if (!order) {
      return errorResponse(res, 'Không tìm thấy đơn hàng', 404, 'ORDER_NOT_FOUND');
    }

    // Find the latest payment for this order
    const payment = await Payment.findOne({
      order: orderId,
    }).sort({ createdAt: -1 });

    if (!payment) {
      return errorResponse(res, 'Không tìm thấy thanh toán', 404, 'PAYMENT_NOT_FOUND');
    }

    // If payment is still pending, query MoMo for latest status
    if (payment.status === 'pending' || payment.status === 'processing') {
      try {
        const momoStatus = await momoService.queryTransactionStatus(
          payment.momoOrderId,
          payment.requestId
        );

        if (momoStatus.resultCode !== undefined) {
          const status = momoService.parseResultCode(momoStatus.resultCode);

          // Update payment if status changed
          if (payment.status !== status) {
            payment.status = status;
            payment.resultCode = momoStatus.resultCode;
            payment.message = momoStatus.message;
            if (momoStatus.transId) {
              payment.transId = momoStatus.transId;
            }
            await payment.save();

            // Update order status
            if (status === 'success') {
              order.paymentStatus = 'paid';
              if (order.status === 'pending') {
                order.status = 'confirmed';
                order.confirmedAt = new Date();
              }
              await order.save();
            } else if (status === 'failed' || status === 'cancelled') {
              order.paymentStatus = 'failed';
              await order.save();
            }
          }
        }
      } catch (queryError) {
        console.error('MoMo query status error:', queryError);
        // Continue with current payment status
      }
    }

    return successResponse(res, {
      payment: {
        id: payment._id,
        requestId: payment.requestId,
        momoOrderId: payment.momoOrderId,
        amount: payment.amount,
        status: payment.status,
        statusText: payment.statusText,
        resultCode: payment.resultCode,
        message: payment.message,
        transId: payment.transId,
        createdAt: payment.createdAt,
      },
      order: {
        id: order._id,
        orderNumber: order.orderNumber,
        status: order.status,
        paymentStatus: order.paymentStatus,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get payment details by order ID
 * @route   GET /api/payments/:orderId
 * @access  Private
 */
const getPaymentByOrder = async (req, res, next) => {
  try {
    const { orderId } = req.params;

    // Find the order and validate ownership
    const order = await Order.findOne({
      _id: orderId,
      user: req.user._id,
    });

    if (!order) {
      return errorResponse(res, 'Không tìm thấy đơn hàng', 404, 'ORDER_NOT_FOUND');
    }

    // Find the latest payment for this order
    const payment = await Payment.findOne({
      order: orderId,
    }).sort({ createdAt: -1 });

    if (!payment) {
      return errorResponse(res, 'Không tìm thấy thanh toán', 404, 'PAYMENT_NOT_FOUND');
    }

    return successResponse(res, {
      payment: {
        id: payment._id,
        method: payment.method,
        requestId: payment.requestId,
        momoOrderId: payment.momoOrderId,
        amount: payment.amount,
        status: payment.status,
        statusText: payment.statusText,
        resultCode: payment.resultCode,
        message: payment.message,
        transId: payment.transId,
        payUrl: payment.payUrl,
        deeplink: payment.deeplink,
        createdAt: payment.createdAt,
        updatedAt: payment.updatedAt,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createMomoPayment,
  handleMomoIpn,
  checkMomoPaymentStatus,
  getPaymentByOrder,
};
