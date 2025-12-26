const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Coupon = require('../models/Coupon');
const Review = require('../models/Review');
const { successResponse, errorResponse } = require('../utils/response');
const { sendOrderStatusUpdateEmail } = require('../utils/emailService');

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
  getAllCoupons,
  createCoupon,
  updateCoupon,
  deleteCoupon,
  getAllReviews,
  approveReview,
  deleteReview,
  getRevenueReport,
  getProductReport,
  getOrderReport
};
