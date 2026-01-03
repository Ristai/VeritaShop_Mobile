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
  getFlaggedReviews,
  approveReviewModeration,
  rejectReviewModeration,
  getModerationCategories,
  getRevenueReport,
  getProductReport,
  getOrderReport,
  getAllCarts,
  getCartByUser,
  updateCartItem,
  deleteCartItem,
  clearUserCart
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
router.post('/users', createUser);
router.put('/users/:id', updateUser);
router.put('/users/:id/status', updateUserStatus);
router.delete('/users/:id', deleteUser);
router.post('/users/:id/reset-password', resetUserPassword);

// Carts
router.get('/carts', getAllCarts);
router.get('/carts/:userId', getCartByUser);
router.put('/carts/:userId/items/:itemId', updateCartItem);
router.delete('/carts/:userId/items/:itemId', deleteCartItem);
router.delete('/carts/:userId', clearUserCart);

// Coupons
router.get('/coupons', getAllCoupons);
router.post('/coupons', createCoupon);
router.put('/coupons/:id', updateCoupon);
router.delete('/coupons/:id', deleteCoupon);

// Reviews
router.get('/reviews', getAllReviews);
router.get('/reviews/flagged', getFlaggedReviews);
router.get('/reviews/moderation-categories', getModerationCategories);
router.put('/reviews/:id/approve', approveReview);
router.put('/reviews/:id/moderation/approve', approveReviewModeration);
router.put('/reviews/:id/moderation/reject', rejectReviewModeration);
router.delete('/reviews/:id', deleteReview);

// Reports
router.get('/reports/revenue', getRevenueReport);
router.get('/reports/products', getProductReport);
router.get('/reports/orders', getOrderReport);

module.exports = router;
