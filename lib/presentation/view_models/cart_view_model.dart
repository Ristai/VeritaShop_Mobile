import 'package:flutter/material.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';

/// ViewModel cho giỏ hàng sử dụng ChangeNotifier
class CartViewModel extends ChangeNotifier {
  final CartRepository _cartRepository;
  
  List<CartModel> _cartItems = [];
  CartSummary? _cartSummary;
  bool _isLoading = false;
  String? _errorMessage;

  CartViewModel({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepository();

  // Getters
  List<CartModel> get cartItems => List.unmodifiable(_cartItems);
  CartSummary? get cartSummary => _cartSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Tải danh sách sản phẩm trong giỏ hàng
  Future<void> loadCartItems() async {
    _setLoading(true);
    _clearError();

    try {
      print('CartViewModel: Loading cart items...');
      final cartData = await _cartRepository.getCart();
      print('CartViewModel: Got ${cartData.items.length} items, total: ${cartData.total}');
      _cartItems = cartData.items;
      _cartSummary = CartSummary(
        items: cartData.items,
        subtotal: cartData.subtotal,
        shippingFee: cartData.shippingFee,
        tax: cartData.tax,
        total: cartData.total,
      );
      notifyListeners();
    } catch (e) {
      print('CartViewModel: Error loading cart: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<bool> addToCart({
    required String productId,
    required int quantity,
    required Map<String, dynamic> color,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cartRepository.addToCart(
        productId: productId,
        quantity: quantity,
        color: color,
      );
      
      if (result != null) {
        _cartItems = result.items;
        _cartSummary = CartSummary(
          items: result.items,
          subtotal: result.subtotal,
          shippingFee: result.shippingFee,
          tax: result.tax,
          total: result.total,
        );
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật số lượng sản phẩm trong giỏ hàng
  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cartRepository.updateCartItem(cartItemId, newQuantity);
      
      if (result != null) {
        _cartItems = result.items;
        _cartSummary = CartSummary(
          items: result.items,
          subtotal: result.subtotal,
          shippingFee: result.shippingFee,
          tax: result.tax,
          total: result.total,
        );
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  Future<bool> removeFromCart(String cartItemId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _cartRepository.removeFromCart(cartItemId);
      
      if (result != null) {
        _cartItems = result.items;
        _cartSummary = CartSummary(
          items: result.items,
          subtotal: result.subtotal,
          shippingFee: result.shippingFee,
          tax: result.tax,
          total: result.total,
        );
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Xóa tất cả sản phẩm khỏi giỏ hàng
  Future<bool> clearCart() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _cartRepository.clearCart();
      
      if (success) {
        _cartItems.clear();
        _cartSummary = null;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Tăng số lượng sản phẩm
  Future<bool> increaseQuantity(String cartItemId) async {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    return await updateQuantity(cartItemId, item.quantity + 1);
  }

  /// Giảm số lượng sản phẩm
  Future<bool> decreaseQuantity(String cartItemId) async {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    if (item.quantity > 1) {
      return await updateQuantity(cartItemId, item.quantity - 1);
    }
    return true;
  }

  // Private helper methods

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
