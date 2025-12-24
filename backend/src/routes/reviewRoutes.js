const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  getProductReviews,
  createReview,
  updateReview,
  deleteReview,
  likeReview,
  getMyReviews,
} = require('../controllers/reviewController');
const { auth, optionalAuth } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Validation rules
const createReviewValidation = [
  body('productId')
    .notEmpty().withMessage('Vui lòng chọn sản phẩm')
    .isMongoId().withMessage('ID sản phẩm không hợp lệ'),
  body('rating')
    .notEmpty().withMessage('Vui lòng đánh giá sản phẩm')
    .isInt({ min: 1, max: 5 }).withMessage('Đánh giá từ 1 đến 5 sao'),
  body('text')
    .notEmpty().withMessage('Vui lòng nhập nội dung đánh giá')
    .isLength({ max: 2000 }).withMessage('Nội dung không quá 2000 ký tự'),
  body('title')
    .optional()
    .isLength({ max: 100 }).withMessage('Tiêu đề không quá 100 ký tự'),
];

const updateReviewValidation = [
  body('rating')
    .optional()
    .isInt({ min: 1, max: 5 }).withMessage('Đánh giá từ 1 đến 5 sao'),
  body('text')
    .optional()
    .isLength({ max: 2000 }).withMessage('Nội dung không quá 2000 ký tự'),
  body('title')
    .optional()
    .isLength({ max: 100 }).withMessage('Tiêu đề không quá 100 ký tự'),
];

// Public routes
router.get('/product/:productId', getProductReviews);

// Protected routes
router.use(auth);

router.get('/my-reviews', getMyReviews);
router.post('/', createReviewValidation, validate, createReview);
router.put('/:id', updateReviewValidation, validate, updateReview);
router.delete('/:id', deleteReview);
router.post('/:id/like', likeReview);

module.exports = router;
