const express = require('express');
const router = express.Router();
const { adminAuth } = require('../middleware/adminAuth');
const {
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
} = require('../controllers/adminController');

// All routes require admin authentication
router.use(adminAuth);

// Dashboard
router.get('/dashboard', getDashboardStats);

// Products
router.get('/products', getAllProducts);
router.post('/products', createProduct);
router.put('/products/:id', updateProduct);
router.delete('/products/:id', deleteProduct);

// Orders
router.get('/orders', getAllOrders);
router.put('/orders/:id/status', updateOrderStatus);
router.post('/orders/:id/refund', refundOrder);

// Users
router.get('/users', getAllUsers);
router.put('/users/:id/status', updateUserStatus);

// Coupons
router.get('/coupons', getAllCoupons);
router.post('/coupons', createCoupon);
router.put('/coupons/:id', updateCoupon);
router.delete('/coupons/:id', deleteCoupon);

// Reviews
router.get('/reviews', getAllReviews);
router.put('/reviews/:id/approve', approveReview);
router.delete('/reviews/:id', deleteReview);

// Reports
router.get('/reports/revenue', getRevenueReport);
router.get('/reports/products', getProductReport);
router.get('/reports/orders', getOrderReport);

module.exports = router;
