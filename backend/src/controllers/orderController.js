const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const User = require('../models/User');
const Coupon = require('../models/Coupon');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');
const { sendOrderConfirmationEmail, sendOrderStatusUpdateEmail } = require('../utils/emailService');
const { createNotification } = require('./notificationController');

// @desc    Create order from cart
// @route   POST /api/orders
const createOrder = async (req, res, next) => {
  try {
    const { shippingAddress, paymentMethod = 'COD', note, couponCode, items: directItems } = req.body;

    // Validate shipping address
    if (!shippingAddress || !shippingAddress.fullName || !shippingAddress.phone || 
        !shippingAddress.province || !shippingAddress.district || 
        !shippingAddress.ward || !shippingAddress.streetAddress) {
      return errorResponse(res, 'Vui lòng nhập đầy đủ địa chỉ giao hàng', 400, 'INVALID_ADDRESS');
    }

    let itemsToProcess = [];

    if (directItems && Array.isArray(directItems) && directItems.length > 0) {
      // Handle direct checkout items
      itemsToProcess = directItems;
    } else {
      // Get user's cart
      const cart = await Cart.findOne({ user: req.user._id }).populate({
        path: 'items.product',
        select: 'name brand price images stock isActive',
      });

      if (!cart || cart.items.length === 0) {
        return errorResponse(res, 'Giỏ hàng trống hoặc không có sản phẩm', 400, 'EMPTY_CART');
      }
      
      // Map cart items to the format expected for processing
      itemsToProcess = cart.items.map(item => ({
        product: item.product, // Populated product object
        color: item.color,
        quantity: item.quantity,
        price: item.price
      }));
    }

    // Validate stock and prepare order items
    const orderItems = [];
    const stockUpdates = [];

    for (const item of itemsToProcess) {
      // If direct checkout, product might be just an ID string, need to fetch it
      let product = item.product;
      
      // Check if product is just an ID (direct checkout case) or populated object (cart case)
      if (!product._id) { 
          product = await Product.findById(item.product);
      }

      if (!product || !product.isActive) {
        return errorResponse(res, `Sản phẩm "${product?.name || 'không xác định'}" không còn bán`, 400, 'PRODUCT_INACTIVE');
      }

      if (product.stock < item.quantity) {
        return errorResponse(res, `Sản phẩm "${product.name}" không đủ số lượng (còn ${product.stock})`, 400, 'INSUFFICIENT_STOCK');
      }

      orderItems.push({
        product: product._id,
        name: product.name,
        brand: product.brand,
        image: product.images[0] || '',
        color: item.color,
        quantity: item.quantity,
        price: product.price, // Use current price from DB to prevent client manipulation
      });

      stockUpdates.push({
        productId: product._id,
        quantity: item.quantity,
      });
    }

    // Calculate totals
    const subtotal = orderItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const shippingFee = subtotal >= 500000 ? 0 : 30000;
    const tax = Math.round(subtotal * 0.1);
    
    // Apply coupon if provided
    let discount = 0;
    let appliedCoupon = null;
    
    if (couponCode) {
      const coupon = await Coupon.findOne({ code: couponCode.toUpperCase() });
      if (coupon) {
        const validation = coupon.isValid(req.user._id, subtotal);
        if (validation.valid) {
          discount = coupon.calculateDiscount(subtotal);
          appliedCoupon = {
            code: coupon.code,
            discountType: coupon.discountType,
            discountValue: coupon.discountValue,
            discountAmount: discount,
          };
          
          // Mark coupon as used
          coupon.usedCount += 1;
          coupon.usedByUsers.push({ user: req.user._id });
          await coupon.save();
        }
      }
    }
    
    const total = subtotal + shippingFee + tax - discount;

    // Create order
    const order = await Order.create({
      user: req.user._id,
      items: orderItems,
      shippingAddress,
      paymentMethod,
      subtotal,
      shippingFee,
      tax,
      discount,
      coupon: appliedCoupon,
      total,
      note,
      // Set payment status based on payment method
      paymentStatus: paymentMethod === 'COD' ? 'pending' : 'pending',
    });

    // Update product stock
    for (const update of stockUpdates) {
      await Product.findByIdAndUpdate(update.productId, {
        $inc: { stock: -update.quantity },
      });
    }

    // Only clear cart immediately for COD orders created FROM THE CART (not direct checkout)
    // For online payment methods, cart is cleared after successful payment
    if (paymentMethod === 'COD' && !directItems) {
      // Re-fetch cart in case we didn't fetch it earlier (direct checkout flow)
      const cartToClear = await Cart.findOne({ user: req.user._id });
      if (cartToClear) {
        cartToClear.items = [];
        await cartToClear.save();
      }
    }

    // Send order confirmation email (async, don't wait)
    const user = await User.findById(req.user._id);
    if (user && user.email) {
      sendOrderConfirmationEmail(order, user).catch(err => {
        console.error('Failed to send order confirmation email:', err);
      });
    }

    // Create notification for order confirmation
    createNotification({
      userId: req.user._id,
      type: 'order',
      title: 'Đặt hàng thành công',
      message: `Đơn hàng #${order.orderNumber} đã được xác nhận. ${paymentMethod === 'COD' ? 'Thanh toán khi nhận hàng.' : 'Vui lòng hoàn tất thanh toán.'}`,
      data: { orderId: order._id.toString(), orderNumber: order.orderNumber },
    }).catch(err => {
      console.error('Failed to create order notification:', err);
    });

    return successResponse(res, {
      order: {
        id: order._id,
        orderNumber: order.orderNumber,
        items: order.items,
        shippingAddress: order.shippingAddress,
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        subtotal: order.subtotal,
        shippingFee: order.shippingFee,
        tax: order.tax,
        discount: order.discount,
        coupon: order.coupon,
        total: order.total,
        status: order.status,
        statusText: order.statusText,
        note: order.note,
        createdAt: order.createdAt,
      },
      // Indicate if payment is required (for MoMo and other online methods)
      requiresPayment: paymentMethod !== 'COD',
      emailSent: true,
    }, 'Đặt hàng thành công', 201);
  } catch (error) {
    next(error);
  }
};

// @desc    Get user's orders
// @route   GET /api/orders
const getOrders = async (req, res, next) => {
  try {
    const { page = 1, limit = 10, status } = req.query;

    const query = { user: req.user._id };
    if (status) {
      query.status = status;
    }

    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    const [orders, total] = await Promise.all([
      Order.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Order.countDocuments(query),
    ]);

    const totalPages = Math.ceil(total / limitNum);

    return paginatedResponse(res, orders, {
      page: pageNum,
      limit: limitNum,
      total,
      totalPages,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get order by ID
// @route   GET /api/orders/:id
const getOrderById = async (req, res, next) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!order) {
      return errorResponse(res, 'Không tìm thấy đơn hàng', 404, 'ORDER_NOT_FOUND');
    }

    return successResponse(res, order);
  } catch (error) {
    next(error);
  }
};

// @desc    Get order by order number
// @route   GET /api/orders/number/:orderNumber
const getOrderByNumber = async (req, res, next) => {
  try {
    const order = await Order.findOne({
      orderNumber: req.params.orderNumber,
      user: req.user._id,
    });

    if (!order) {
      return errorResponse(res, 'Không tìm thấy đơn hàng', 404, 'ORDER_NOT_FOUND');
    }

    return successResponse(res, order);
  } catch (error) {
    next(error);
  }
};

// @desc    Cancel order
// @route   PUT /api/orders/:id/cancel
const cancelOrder = async (req, res, next) => {
  try {
    const { reason } = req.body;

    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!order) {
      return errorResponse(res, 'Không tìm thấy đơn hàng', 404, 'ORDER_NOT_FOUND');
    }

    // Only pending orders can be cancelled
    if (order.status !== 'pending') {
      return errorResponse(res, 'Không thể hủy đơn hàng đã xử lý', 400, 'CANNOT_CANCEL');
    }

    // Restore product stock
    for (const item of order.items) {
      await Product.findByIdAndUpdate(item.product, {
        $inc: { stock: item.quantity },
      });
    }

    // Update order status
    order.status = 'cancelled';
    order.cancelReason = reason || 'Khách hàng hủy đơn';
    order.cancelledAt = new Date();
    await order.save();

    return successResponse(res, {
      id: order._id,
      orderNumber: order.orderNumber,
      status: order.status,
      statusText: order.statusText,
      cancelReason: order.cancelReason,
      cancelledAt: order.cancelledAt,
    }, 'Đã hủy đơn hàng');
  } catch (error) {
    next(error);
  }
};

// @desc    Reorder (add previous order items to cart)
// @route   POST /api/orders/:id/reorder
const reorder = async (req, res, next) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!order) {
      return errorResponse(res, 'Không tìm thấy đơn hàng', 404, 'ORDER_NOT_FOUND');
    }

    // Get or create cart
    let cart = await Cart.findOne({ user: req.user._id });
    if (!cart) {
      cart = new Cart({ user: req.user._id, items: [] });
    }

    // Add order items to cart
    const errors = [];
    for (const orderItem of order.items) {
      const product = await Product.findById(orderItem.product);
      
      if (!product || !product.isActive) {
        errors.push(`${orderItem.name} không còn bán`);
        continue;
      }

      if (product.stock === 0) {
        errors.push(`${orderItem.name} đã hết hàng`);
        continue;
      }

      // Check if item already in cart
      const existingIndex = cart.items.findIndex(
        item => item.product.toString() === orderItem.product.toString() && 
                item.color.name === orderItem.color.name
      );

      const quantityToAdd = Math.min(orderItem.quantity, product.stock);

      if (existingIndex > -1) {
        const newQty = Math.min(cart.items[existingIndex].quantity + quantityToAdd, product.stock);
        cart.items[existingIndex].quantity = newQty;
        cart.items[existingIndex].price = product.price;
      } else {
        cart.items.push({
          product: orderItem.product,
          color: orderItem.color,
          quantity: quantityToAdd,
          price: product.price,
        });
      }
    }

    await cart.save();

    // Populate cart
    const populatedCart = await Cart.findById(cart._id).populate({
      path: 'items.product',
      select: 'name brand price originalPrice images stock',
    });

    return successResponse(res, {
      cart: {
        items: populatedCart.items,
        itemCount: populatedCart.itemCount,
        subtotal: populatedCart.subtotal,
        total: populatedCart.total,
      },
      errors: errors.length > 0 ? errors : undefined,
    }, errors.length > 0 ? 'Đã thêm một số sản phẩm vào giỏ hàng' : 'Đã thêm vào giỏ hàng');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createOrder,
  getOrders,
  getOrderById,
  getOrderByNumber,
  cancelOrder,
  reorder,
};
