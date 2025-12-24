const express = require('express');
const router = express.Router();
const {
  getProducts,
  getProductById,
  searchProducts,
  getProductsByBrand,
  getBrands,
  getFeaturedProducts,
  getRelatedProducts,
} = require('../controllers/productController');

// Public routes - no authentication required

// Get all brands (must be before /:id to avoid conflict)
router.get('/brands', getBrands);

// Get featured products
router.get('/featured', getFeaturedProducts);

// Search products
router.get('/search', searchProducts);

// Get products by brand
router.get('/brand/:brand', getProductsByBrand);

// Get all products with filtering
router.get('/', getProducts);

// Get single product by ID
router.get('/:id', getProductById);

// Get related products
router.get('/:id/related', getRelatedProducts);

module.exports = router;
