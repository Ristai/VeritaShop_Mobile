const Cart = require('../models/Cart');
const Product = require('../models/Product');
const { successResponse, errorResponse } = require('../utils/response');

// @desc    Get user's cart
// @route   GET /api/cart
const getCart = async (req, res, next) => {
  try {
    let cart = await Cart.findOne({ user: req.user._id })
      .populate({
        path: 'items.product',
        select: 'name brand price originalPrice images stock condition warranty',
      });

    if (!cart) {
      cart = await Cart.create({ user: req.user._id, items: [] });
    }

    return successResponse(res, {
      items: cart.items,
      itemCount: cart.itemCount,
      subtotal: cart.subtotal,
      shippingFee: cart.shippingFee,
      tax: cart.tax,
      total: cart.total,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Add item to cart
// @route   POST /api/cart
const addToCart = async (req, res, next) => {
  try {
    const { productId, quantity = 1, color } = req.body;

    // Validate product
    const product = await Product.findById(productId);
    if (!product) {
      return errorResponse(res, 'Không tìm thấy sản phẩm', 404, 'PRODUCT_NOT_FOUND');
    }

    if (!product.isActive) {
      return errorResponse(res, 'Sản phẩm không còn bán', 400, 'PRODUCT_INACTIVE');
    }

    if (product.stock === 0) {
      return errorResponse(res, 'Sản phẩm đã hết hàng', 400, 'OUT_OF_STOCK');
    }

    // Validate color - allow default if product has no colors
    let selectedColor = { name: 'Mặc định', code: null };
    
    if (product.colors && product.colors.length > 0) {
      // Product has colors - require valid selection
      if (!color || !color.name) {
        return errorResponse(res, 'Vui lòng chọn màu sắc', 400, 'COLOR_REQUIRED');
      }
      
      const validColor = product.colors.find(c => c.name === color.name);
      if (!validColor) {
        return errorResponse(res, 'Màu sắc không hợp lệ', 400, 'INVALID_COLOR');
      }
      selectedColor = { name: validColor.name, code: validColor.code };
    } else if (color && color.name) {
      // No colors defined but user provided one - use it
      selectedColor = { name: color.name, code: color.code || null };
    }

    // Get or create cart
    let cart = await Cart.findOne({ user: req.user._id });
    if (!cart) {
      cart = new Cart({ user: req.user._id, items: [] });
    }

    // Check if product with same color already in cart
    const existingItemIndex = cart.items.findIndex(
      item => item.product.toString() === productId && item.color.name === selectedColor.name
    );

    if (existingItemIndex > -1) {
      // Update quantity
      const newQuantity = cart.items[existingItemIndex].quantity + quantity;
      
      if (newQuantity > product.stock) {
        return errorResponse(res, `Số lượng vượt quá tồn kho (còn ${product.stock})`, 400, 'EXCEED_STOCK');
      }

      cart.items[existingItemIndex].quantity = newQuantity;
      cart.items[existingItemIndex].price = product.price;
    } else {
      // Add new item
      if (quantity > product.stock) {
        return errorResponse(res, `Số lượng vượt quá tồn kho (còn ${product.stock})`, 400, 'EXCEED_STOCK');
      }

      cart.items.push({
        product: productId,
        color: selectedColor,
        quantity,
        price: product.price,
      });
    }

    await cart.save();

    // Populate and return
    cart = await Cart.findById(cart._id).populate({
      path: 'items.product',
      select: 'name brand price originalPrice images stock condition warranty',
    });

    return successResponse(res, {
      items: cart.items,
      itemCount: cart.itemCount,
      subtotal: cart.subtotal,
      shippingFee: cart.shippingFee,
      tax: cart.tax,
      total: cart.total,
    }, 'Đã thêm vào giỏ hàng');
  } catch (error) {
    next(error);
  }
};

// @desc    Update cart item quantity
// @route   PUT /api/cart/:itemId
const updateCartItem = async (req, res, next) => {
  try {
    const { itemId } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity < 0) {
      return errorResponse(res, 'Số lượng không hợp lệ', 400, 'INVALID_QUANTITY');
    }

    const cart = await Cart.findOne({ user: req.user._id });
    if (!cart) {
      return errorResponse(res, 'Giỏ hàng trống', 404, 'CART_NOT_FOUND');
    }

    const itemIndex = cart.items.findIndex(item => item._id.toString() === itemId);
    if (itemIndex === -1) {
      return errorResponse(res, 'Không tìm thấy sản phẩm trong giỏ hàng', 404, 'ITEM_NOT_FOUND');
    }

    if (quantity === 0) {
      // Remove item
      cart.items.splice(itemIndex, 1);
    } else {
      // Check stock
      const product = await Product.findById(cart.items[itemIndex].product);
      if (quantity > product.stock) {
        return errorResponse(res, `Số lượng vượt quá tồn kho (còn ${product.stock})`, 400, 'EXCEED_STOCK');
      }

      cart.items[itemIndex].quantity = quantity;
      cart.items[itemIndex].price = product.price; // Update price in case it changed
    }

    await cart.save();

    // Populate and return
    const updatedCart = await Cart.findById(cart._id).populate({
      path: 'items.product',
      select: 'name brand price originalPrice images stock condition warranty',
    });

    return successResponse(res, {
      items: updatedCart.items,
      itemCount: updatedCart.itemCount,
      subtotal: updatedCart.subtotal,
      shippingFee: updatedCart.shippingFee,
      tax: updatedCart.tax,
      total: updatedCart.total,
    }, quantity === 0 ? 'Đã xóa sản phẩm' : 'Đã cập nhật số lượng');
  } catch (error) {
    next(error);
  }
};

// @desc    Remove item from cart
// @route   DELETE /api/cart/:itemId
const removeCartItem = async (req, res, next) => {
  try {
    const { itemId } = req.params;

    const cart = await Cart.findOne({ user: req.user._id });
    if (!cart) {
      return errorResponse(res, 'Giỏ hàng trống', 404, 'CART_NOT_FOUND');
    }

    const itemIndex = cart.items.findIndex(item => item._id.toString() === itemId);
    if (itemIndex === -1) {
      return errorResponse(res, 'Không tìm thấy sản phẩm trong giỏ hàng', 404, 'ITEM_NOT_FOUND');
    }

    cart.items.splice(itemIndex, 1);
    await cart.save();

    // Populate and return
    const updatedCart = await Cart.findById(cart._id).populate({
      path: 'items.product',
      select: 'name brand price originalPrice images stock condition warranty',
    });

    return successResponse(res, {
      items: updatedCart.items,
      itemCount: updatedCart.itemCount,
      subtotal: updatedCart.subtotal,
      shippingFee: updatedCart.shippingFee,
      tax: updatedCart.tax,
      total: updatedCart.total,
    }, 'Đã xóa sản phẩm khỏi giỏ hàng');
  } catch (error) {
    next(error);
  }
};

// @desc    Clear cart
// @route   DELETE /api/cart
const clearCart = async (req, res, next) => {
  try {
    const cart = await Cart.findOne({ user: req.user._id });
    if (cart) {
      cart.items = [];
      await cart.save();
    }

    return successResponse(res, {
      items: [],
      itemCount: 0,
      subtotal: 0,
      shippingFee: 30000,
      tax: 0,
      total: 30000,
    }, 'Đã xóa toàn bộ giỏ hàng');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getCart,
  addToCart,
  updateCartItem,
  removeCartItem,
  clearCart,
};
