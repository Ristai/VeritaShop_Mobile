const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Coupon = require('../models/Coupon');
const Review = require('../models/Review');
const Cart = require('../models/Cart');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { successResponse, errorResponse } = require('../utils/response');
const { sendOrderStatusUpdateEmail, sendPasswordResetEmail } = require('../utils/emailService');

// Dashboard Stats
const getDashboardStats = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const weekStart = new Date(today);
    weekStart.setDate(weekStart.getDate() - 7);
    
    const monthStart = new Date(today);
    monthStart.setMonth(monthStart.getMonth() - 1);

    // Revenue calculations
    const [todayRevenue, weekRevenue, monthRevenue, totalRevenue] = await Promise.all([
      Order.aggregate([
        { $match: { createdAt: { $gte: today }, status: { $in: ['delivered', 'completed'] } } },
        { $group: { _id: null, total: { $sum: '$total' } } }
      ]),
      Order.aggregate([
        { $match: { createdAt: { $gte: weekStart }, status: { $in: ['delivered', 'completed'] } } },
        { $group: { _id: null, total: { $sum: '$total' } } }
      ]),
      Order.aggregate([
        { $match: { createdAt: { $gte: monthStart }, status: { $in: ['delivered', 'completed'] } } },
        { $group: { _id: null, total: { $sum: '$total' } } }
      ]),
      Order.aggregate([
        { $match: { status: { $in: ['delivered', 'completed'] } } },
        { $group: { _id: null, total: { $sum: '$total' } } }
      ])
    ]);

    // Order counts
    const [todayOrders, pendingOrders, totalOrders] = await Promise.all([
      Order.countDocuments({ createdAt: { $gte: today } }),
      Order.countDocuments({ status: 'pending' }),
      Order.countDocuments()
    ]);

    // Product counts
    const [totalProducts, outOfStock] = await Promise.all([
      Product.countDocuments(),
      Product.countDocuments({ stock: 0 })
    ]);

    // User counts
    const [totalUsers, newUsersThisMonth] = await Promise.all([
      User.countDocuments({ role: 'customer' }),
      User.countDocuments({ role: 'customer', createdAt: { $gte: monthStart } })
    ]);

    // Recent orders
    const recentOrders = await Order.find()
      .populate('user', 'name email')
      .sort({ createdAt: -1 })
      .limit(10)
      .lean();

    // Top selling products
    const topProducts = await Order.aggregate([
      { $match: { status: { $in: ['delivered', 'completed'] } } },
      { $unwind: '$items' },
      { $group: { _id: '$items.product', totalSold: { $sum: '$items.quantity' }, revenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } } } },
      { $sort: { totalSold: -1 } },
      { $limit: 5 },
      { $lookup: { from: 'products', localField: '_id', foreignField: '_id', as: 'product' } },
      { $unwind: '$product' },
      { $project: { _id: 1, name: '$product.name', image: { $arrayElemAt: ['$product.images', 0] }, totalSold: 1, revenue: 1 } }
    ]);

    successResponse(res, {
      revenue: {
        today: todayRevenue[0]?.total || 0,
        week: weekRevenue[0]?.total || 0,
        month: monthRevenue[0]?.total || 0,
        total: totalRevenue[0]?.total || 0
      },
      orders: {
        today: todayOrders,
        pending: pendingOrders,
        total: totalOrders
      },
      products: {
        total: totalProducts,
        outOfStock
      },
      users: {
        total: totalUsers,
        newThisMonth: newUsersThisMonth
      },
      recentOrders,
      topProducts
    });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Products CRUD
const getAllProducts = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, brand, sort = '-createdAt' } = req.query;
    
    const query = {};
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }
    if (brand) query.brand = brand;

    const products = await Product.find(query)
      .sort(sort)
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .lean();

    const total = await Product.countDocuments(query);

    successResponse(res, { products, pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) } });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const createProduct = async (req, res) => {
  try {
    const product = await Product.create(req.body);
    successResponse(res, { product }, 'Tạo sản phẩm thành công', 201);
  } catch (error) {
    errorResponse(res, error.message, 400);
  }
};

const updateProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!product) return errorResponse(res, 'Không tìm thấy sản phẩm', 404);
    successResponse(res, { product }, 'Cập nhật sản phẩm thành công');
  } catch (error) {
    errorResponse(res, error.message, 400);
  }
};

const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) return errorResponse(res, 'Không tìm thấy sản phẩm', 404);
    successResponse(res, null, 'Xóa sản phẩm thành công');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Orders Management
const getAllOrders = async (req, res) => {
  try {
    const { page = 1, limit = 20, status, sort = '-createdAt' } = req.query;
    
    const query = {};
    if (status) query.status = status;

    const orders = await Order.find(query)
      .populate('user', 'name email phone')
      .populate('items.product', 'name images')
      .sort(sort)
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .lean();

    const total = await Order.countDocuments(query);

    successResponse(res, { orders, pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) } });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'completed', 'cancelled', 'refunded'];
    
    if (!validStatuses.includes(status)) {
      return errorResponse(res, 'Trạng thái không hợp lệ', 400);
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    ).populate('user', 'name email');

    if (!order) return errorResponse(res, 'Không tìm thấy đơn hàng', 404);

    // Send email notification
    if (order.user?.email) {
      try {
        await sendOrderStatusUpdateEmail(order.user.email, order.orderNumber, status);
      } catch (emailError) {
        console.error('Failed to send status update email:', emailError);
      }
    }

    successResponse(res, { order }, 'Cập nhật trạng thái thành công');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const refundOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return errorResponse(res, 'Không tìm thấy đơn hàng', 404);
    
    if (!['delivered', 'completed'].includes(order.status)) {
      return errorResponse(res, 'Chỉ có thể hoàn tiền đơn hàng đã giao', 400);
    }

    order.status = 'refunded';
    await order.save();

    successResponse(res, { order }, 'Hoàn tiền thành công');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Users Management
const getAllUsers = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, sort = '-createdAt' } = req.query;
    
    const query = { role: 'customer' };
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } }
      ];
    }

    const users = await User.find(query)
      .select('-password -refreshToken')
      .sort(sort)
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .lean();

    const total = await User.countDocuments(query);

    successResponse(res, { users, pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) } });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const updateUserStatus = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return errorResponse(res, 'Không tìm thấy người dùng', 404);
    if (user.role === 'admin') return errorResponse(res, 'Không thể thay đổi trạng thái admin', 400);

    user.isActive = !user.isActive;
    await user.save();

    successResponse(res, { user }, `Đã ${user.isActive ? 'kích hoạt' : 'khóa'} tài khoản`);
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Create User (Admin)
const createUser = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    // Check if email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return errorResponse(res, 'Email đã được sử dụng', 400);
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
      name,
      email,
      phone,
      password: hashedPassword,
      role: 'customer',
      isActive: true,
    });

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    successResponse(res, { user: userResponse }, 'Tạo người dùng thành công', 201);
  } catch (error) {
    errorResponse(res, error.message, 400);
  }
};

// Update User (Admin)
const updateUser = async (req, res) => {
  try {
    const { name, email, phone, address } = req.body;

    const user = await User.findById(req.params.id);
    if (!user) return errorResponse(res, 'Không tìm thấy người dùng', 404);
    if (user.role === 'admin') return errorResponse(res, 'Không thể chỉnh sửa tài khoản admin', 400);

    // Check if email is being changed and if it's already used
    if (email && email !== user.email) {
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return errorResponse(res, 'Email đã được sử dụng', 400);
      }
    }

    // Update fields
    if (name) user.name = name;
    if (email) user.email = email;
    if (phone) user.phone = phone;
    if (address) user.address = address;

    await user.save();

    // Remove sensitive fields from response
    const userResponse = user.toObject();
    delete userResponse.password;
    delete userResponse.refreshToken;

    successResponse(res, { user: userResponse }, 'Cập nhật người dùng thành công');
  } catch (error) {
    errorResponse(res, error.message, 400);
  }
};

// Delete User (Admin)
const deleteUser = async (req, res) => {
  try {
    const userId = req.params.id;

    // Prevent admin from deleting themselves
    if (userId === req.user._id.toString()) {
      return errorResponse(res, 'Không thể xóa tài khoản của chính bạn', 400);
    }

    const user = await User.findById(userId);
    if (!user) return errorResponse(res, 'Không tìm thấy người dùng', 404);
    if (user.role === 'admin') return errorResponse(res, 'Không thể xóa tài khoản admin', 400);

    // Delete user's cart
    await Cart.findOneAndDelete({ user: userId });

    // Delete the user
    await User.findByIdAndDelete(userId);

    successResponse(res, null, 'Xóa người dùng thành công');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Reset User Password (Admin)
const resetUserPassword = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return errorResponse(res, 'Không tìm thấy người dùng', 404);
    if (user.role === 'admin') return errorResponse(res, 'Không thể reset mật khẩu admin', 400);

    // Generate temporary password
    const tempPassword = crypto.randomBytes(4).toString('hex'); // 8 character password

    // Hash and save new password
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(tempPassword, salt);
    await user.save();

    // Send email with new password
    try {
      await sendPasswordResetEmail(user.email, user.name, tempPassword);
    } catch (emailError) {
      console.error('Failed to send password reset email:', emailError);
    }

    successResponse(res, { email: user.email }, 'Đã reset mật khẩu và gửi email cho người dùng');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Coupons Management
const getAllCoupons = async (req, res) => {
  try {
    const coupons = await Coupon.find().sort('-createdAt').lean();
    successResponse(res, { coupons });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const createCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.create(req.body);
    successResponse(res, { coupon }, 'Tạo mã giảm giá thành công', 201);
  } catch (error) {
    errorResponse(res, error.message, 400);
  }
};

const updateCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!coupon) return errorResponse(res, 'Không tìm thấy mã giảm giá', 404);
    successResponse(res, { coupon }, 'Cập nhật mã giảm giá thành công');
  } catch (error) {
    errorResponse(res, error.message, 400);
  }
};

const deleteCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.findByIdAndDelete(req.params.id);
    if (!coupon) return errorResponse(res, 'Không tìm thấy mã giảm giá', 404);
    successResponse(res, null, 'Xóa mã giảm giá thành công');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Reviews Management
const getAllReviews = async (req, res) => {
  try {
    const { page = 1, limit = 20, status, sort = '-createdAt' } = req.query;
    
    const query = {};
    if (status) query.isApproved = status === 'approved';

    const reviews = await Review.find(query)
      .populate('user', 'name email avatar')
      .populate('product', 'name images')
      .sort(sort)
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .lean();

    const total = await Review.countDocuments(query);

    successResponse(res, { reviews, pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) } });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const approveReview = async (req, res) => {
  try {
    const review = await Review.findByIdAndUpdate(
      req.params.id,
      { isApproved: true },
      { new: true }
    );
    if (!review) return errorResponse(res, 'Không tìm thấy đánh giá', 404);
    successResponse(res, { review }, 'Đã phê duyệt đánh giá');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const deleteReview = async (req, res) => {
  try {
    const review = await Review.findByIdAndDelete(req.params.id);
    if (!review) return errorResponse(res, 'Không tìm thấy đánh giá', 404);
    
    // Update product rating
    const productReviews = await Review.find({ product: review.product });
    const avgRating = productReviews.length > 0
      ? productReviews.reduce((sum, r) => sum + r.rating, 0) / productReviews.length
      : 0;
    await Product.findByIdAndUpdate(review.product, { rating: avgRating, reviewCount: productReviews.length });

    successResponse(res, null, 'Đã xóa đánh giá');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Reports
const getRevenueReport = async (req, res) => {
  try {
    const { from, to, groupBy = 'day' } = req.query;
    
    const startDate = from ? new Date(from) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const endDate = to ? new Date(to) : new Date();

    let dateFormat;
    if (groupBy === 'month') dateFormat = '%Y-%m';
    else if (groupBy === 'week') dateFormat = '%Y-W%V';
    else dateFormat = '%Y-%m-%d';

    const revenueData = await Order.aggregate([
      { 
        $match: { 
          createdAt: { $gte: startDate, $lte: endDate },
          status: { $in: ['delivered', 'completed'] }
        } 
      },
      {
        $group: {
          _id: { $dateToString: { format: dateFormat, date: '$createdAt' } },
          revenue: { $sum: '$total' },
          orders: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    successResponse(res, { data: revenueData, from: startDate, to: endDate });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const getProductReport = async (req, res) => {
  try {
    const topProducts = await Order.aggregate([
      { $match: { status: { $in: ['delivered', 'completed'] } } },
      { $unwind: '$items' },
      { $group: { _id: '$items.product', totalSold: { $sum: '$items.quantity' }, revenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } } } },
      { $sort: { revenue: -1 } },
      { $limit: 10 },
      { $lookup: { from: 'products', localField: '_id', foreignField: '_id', as: 'product' } },
      { $unwind: '$product' },
      { $project: { name: '$product.name', brand: '$product.brand', image: { $arrayElemAt: ['$product.images', 0] }, totalSold: 1, revenue: 1 } }
    ]);

    const lowStock = await Product.find({ stock: { $lte: 10 } })
      .select('name brand stock images')
      .sort('stock')
      .limit(10)
      .lean();

    successResponse(res, { topProducts, lowStock });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const getOrderReport = async (req, res) => {
  try {
    const statusDistribution = await Order.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } }
    ]);

    const paymentMethods = await Order.aggregate([
      { $group: { _id: '$paymentMethod', count: { $sum: 1 }, total: { $sum: '$total' } } }
    ]);

    successResponse(res, { statusDistribution, paymentMethods });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

// Cart Management (Admin)
const getAllCarts = async (req, res) => {
  try {
    const { page = 1, limit = 20, search } = req.query;

    // Find carts that have items
    let query = { 'items.0': { $exists: true } };

    // If search provided, find user IDs matching search first
    if (search) {
      const matchingUsers = await User.find({
        $or: [
          { name: { $regex: search, $options: 'i' } },
          { email: { $regex: search, $options: 'i' } },
          { phone: { $regex: search, $options: 'i' } }
        ]
      }).select('_id');

      const userIds = matchingUsers.map(u => u._id);
      query.user = { $in: userIds };
    }

    const carts = await Cart.find(query)
      .populate('user', 'name email phone avatar')
      .populate('items.product', 'name images price brand')
      .sort('-updatedAt')
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .lean();

    const total = await Cart.countDocuments(query);

    // Add computed totals to each cart
    const cartsWithTotals = carts.map(cart => ({
      ...cart,
      itemCount: cart.items.reduce((sum, item) => sum + item.quantity, 0),
      subtotal: cart.items.reduce((sum, item) => sum + (item.price * item.quantity), 0),
    }));

    successResponse(res, {
      carts: cartsWithTotals,
      pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) }
    });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const getCartByUser = async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.params.userId })
      .populate('user', 'name email phone avatar')
      .populate('items.product', 'name images price brand stock')
      .lean();

    if (!cart) {
      return successResponse(res, { cart: { items: [], user: null } });
    }

    // Add computed totals
    const cartWithTotals = {
      ...cart,
      itemCount: cart.items.reduce((sum, item) => sum + item.quantity, 0),
      subtotal: cart.items.reduce((sum, item) => sum + (item.price * item.quantity), 0),
    };

    successResponse(res, { cart: cartWithTotals });
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const updateCartItem = async (req, res) => {
  try {
    const { userId, itemId } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity < 1) {
      return errorResponse(res, 'Số lượng phải lớn hơn 0', 400);
    }

    const cart = await Cart.findOne({ user: userId });
    if (!cart) return errorResponse(res, 'Không tìm thấy giỏ hàng', 404);

    const itemIndex = cart.items.findIndex(item => item._id.toString() === itemId);
    if (itemIndex === -1) return errorResponse(res, 'Không tìm thấy sản phẩm trong giỏ hàng', 404);

    cart.items[itemIndex].quantity = quantity;
    await cart.save();

    const updatedCart = await Cart.findById(cart._id)
      .populate('user', 'name email phone')
      .populate('items.product', 'name images price brand')
      .lean();

    successResponse(res, { cart: updatedCart }, 'Cập nhật giỏ hàng thành công');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const deleteCartItem = async (req, res) => {
  try {
    const { userId, itemId } = req.params;

    const cart = await Cart.findOne({ user: userId });
    if (!cart) return errorResponse(res, 'Không tìm thấy giỏ hàng', 404);

    const itemIndex = cart.items.findIndex(item => item._id.toString() === itemId);
    if (itemIndex === -1) return errorResponse(res, 'Không tìm thấy sản phẩm trong giỏ hàng', 404);

    cart.items.splice(itemIndex, 1);
    await cart.save();

    successResponse(res, null, 'Đã xóa sản phẩm khỏi giỏ hàng');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

const clearUserCart = async (req, res) => {
  try {
    const { userId } = req.params;

    const cart = await Cart.findOne({ user: userId });
    if (!cart) return errorResponse(res, 'Không tìm thấy giỏ hàng', 404);

    cart.items = [];
    await cart.save();

    successResponse(res, null, 'Đã xóa toàn bộ giỏ hàng');
  } catch (error) {
    errorResponse(res, error.message, 500);
  }
};

module.exports = {
  getDashboardStats,
  getAllProducts,
  createProduct,
  updateProduct,
  deleteProduct,
  getAllOrders,
  updateOrderStatus,
  refundOrder,
  getAllUsers,
  updateUserStatus,
  createUser,
  updateUser,
  deleteUser,
  resetUserPassword,
  getAllCoupons,
  createCoupon,
  updateCoupon,
  deleteCoupon,
  getAllReviews,
  approveReview,
  deleteReview,
  getRevenueReport,
  getProductReport,
  getOrderReport,
  getAllCarts,
  getCartByUser,
  updateCartItem,
  deleteCartItem,
  clearUserCart
};
