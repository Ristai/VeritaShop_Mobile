const Product = require('../models/Product');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

// @desc    Get all products with filtering, sorting, pagination
// @route   GET /api/products
const getProducts = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      sort = 'newest',
      brand,
      minPrice,
      maxPrice,
      ram,
      rom,
      condition,
      search,
      featured,
    } = req.query;

    // Build query
    const query = { isActive: true };

    // Filter by brand
    if (brand) {
      query.brand = brand;
    }

    // Filter by price range
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    // Filter by specs
    if (ram) query['specs.ram'] = ram;
    if (rom) query['specs.rom'] = rom;

    // Filter by condition
    if (condition) {
      query.condition = condition;
    }

    // Filter featured
    if (featured === 'true') {
      query.isFeatured = true;
    }

    // Search by text
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { brand: { $regex: search, $options: 'i' } },
        { 'specs.chip': { $regex: search, $options: 'i' } },
      ];
    }

    // Sort options
    let sortOption = {};
    switch (sort) {
      case 'price_asc':
        sortOption = { price: 1 };
        break;
      case 'price_desc':
        sortOption = { price: -1 };
        break;
      case 'rating':
        sortOption = { rating: -1 };
        break;
      case 'name_asc':
        sortOption = { name: 1 };
        break;
      case 'name_desc':
        sortOption = { name: -1 };
        break;
      case 'newest':
      default:
        sortOption = { createdAt: -1 };
        break;
    }

    // Pagination
    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    // Execute query
    const [products, total] = await Promise.all([
      Product.find(query)
        .sort(sortOption)
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Product.countDocuments(query),
    ]);

    const totalPages = Math.ceil(total / limitNum);

    return paginatedResponse(res, products, {
      page: pageNum,
      limit: limitNum,
      total,
      totalPages,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single product by ID
// @route   GET /api/products/:id
const getProductById = async (req, res, next) => {
  try {
    const product = await Product.findOne({
      _id: req.params.id,
      isActive: true,
    });

    if (!product) {
      return errorResponse(res, 'Không tìm thấy sản phẩm', 404, 'PRODUCT_NOT_FOUND');
    }

    return successResponse(res, product);
  } catch (error) {
    next(error);
  }
};

// @desc    Search products
// @route   GET /api/products/search
const searchProducts = async (req, res, next) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;

    if (!q || q.trim() === '') {
      return errorResponse(res, 'Vui lòng nhập từ khóa tìm kiếm', 400, 'MISSING_QUERY');
    }

    const query = {
      isActive: true,
      $or: [
        { name: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { brand: { $regex: q, $options: 'i' } },
        { 'specs.chip': { $regex: q, $options: 'i' } },
        { tags: { $regex: q, $options: 'i' } },
      ],
    };

    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    const [products, total] = await Promise.all([
      Product.find(query)
        .sort({ rating: -1, createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Product.countDocuments(query),
    ]);

    const totalPages = Math.ceil(total / limitNum);

    return paginatedResponse(res, products, {
      page: pageNum,
      limit: limitNum,
      total,
      totalPages,
      query: q,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get products by brand
// @route   GET /api/products/brand/:brand
const getProductsByBrand = async (req, res, next) => {
  try {
    const { brand } = req.params;
    const { page = 1, limit = 20, sort = 'newest' } = req.query;

    const validBrands = ['iPhone', 'Samsung', 'Xiaomi', 'OPPO', 'Vivo', 'Other'];
    if (!validBrands.includes(brand)) {
      return errorResponse(res, 'Hãng không hợp lệ', 400, 'INVALID_BRAND');
    }

    const query = { brand, isActive: true };

    // Sort options
    let sortOption = {};
    switch (sort) {
      case 'price_asc':
        sortOption = { price: 1 };
        break;
      case 'price_desc':
        sortOption = { price: -1 };
        break;
      case 'rating':
        sortOption = { rating: -1 };
        break;
      case 'newest':
      default:
        sortOption = { createdAt: -1 };
        break;
    }

    const pageNum = Math.max(1, parseInt(page));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit)));
    const skip = (pageNum - 1) * limitNum;

    const [products, total] = await Promise.all([
      Product.find(query)
        .sort(sortOption)
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Product.countDocuments(query),
    ]);

    const totalPages = Math.ceil(total / limitNum);

    return paginatedResponse(res, products, {
      page: pageNum,
      limit: limitNum,
      total,
      totalPages,
      brand,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all available brands
// @route   GET /api/products/brands
const getBrands = async (req, res, next) => {
  try {
    const brands = await Product.aggregate([
      { $match: { isActive: true } },
      { $group: { _id: '$brand', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]);

    const brandList = brands.map(b => ({
      name: b._id,
      count: b.count,
    }));

    return successResponse(res, {
      brands: brandList,
      availableBrands: ['iPhone', 'Samsung', 'Xiaomi', 'OPPO', 'Vivo', 'Other'],
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get featured products
// @route   GET /api/products/featured
const getFeaturedProducts = async (req, res, next) => {
  try {
    const { limit = 10 } = req.query;
    const limitNum = Math.min(20, Math.max(1, parseInt(limit)));

    const products = await Product.find({
      isActive: true,
      isFeatured: true,
    })
      .sort({ rating: -1, createdAt: -1 })
      .limit(limitNum)
      .lean();

    return successResponse(res, products);
  } catch (error) {
    next(error);
  }
};

// @desc    Get related products (same brand, different product)
// @route   GET /api/products/:id/related
const getRelatedProducts = async (req, res, next) => {
  try {
    const { limit = 6 } = req.query;
    const product = await Product.findById(req.params.id);

    if (!product) {
      return errorResponse(res, 'Không tìm thấy sản phẩm', 404, 'PRODUCT_NOT_FOUND');
    }

    const relatedProducts = await Product.find({
      _id: { $ne: product._id },
      brand: product.brand,
      isActive: true,
    })
      .sort({ rating: -1 })
      .limit(parseInt(limit))
      .lean();

    return successResponse(res, relatedProducts);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProducts,
  getProductById,
  searchProducts,
  getProductsByBrand,
  getBrands,
  getFeaturedProducts,
  getRelatedProducts,
};
