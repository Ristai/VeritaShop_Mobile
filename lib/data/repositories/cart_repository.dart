import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cart_model.dart';
import '../../core/network/api_service.dart';

/// Repository xử lý logic nghiệp vụ cho giỏ hàng
class CartRepository {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;
  
  // Cache for cart data
  CartData? _cachedCart;
  
  CartRepository({
    ApiService? apiService,
    FlutterSecureStorage? secureStorage,
  }) : _apiService = apiService ?? ApiService.instance,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Lấy giỏ hàng của user
  Future<CartData> getCart() async {
    try {
      final response = await _apiService.getCart();
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _cachedCart = CartData.fromMap(data);
        return _cachedCart!;
      }
      
      return CartData.empty();
    } catch (e) {
      // Return cached data if available
      return _cachedCart ?? CartData.empty();
    }
  }

  /// Lấy tất cả items trong giỏ hàng
  Future<List<CartModel>> getCartItems() async {
    final cart = await getCart();
    return cart.items;
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<CartData?> addToCart({
    required String productId,
    required int quantity,
    required Map<String, dynamic> color,
  }) async {
    try {
      final response = await _apiService.addToCart(
        productId: productId,
        quantity: quantity,
        color: color,
      );
      
      if (response['success'] == true && response['data'] != null) {
        _cachedCart = CartData.fromMap(response['data']);
        return _cachedCart;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cập nhật số lượng item trong giỏ hàng
  Future<CartData?> updateCartItem(String cartItemId, int newQuantity) async {
    try {
      final response = await _apiService.updateCartItem(cartItemId, newQuantity);
      
      if (response['success'] == true && response['data'] != null) {
        _cachedCart = CartData.fromMap(response['data']);
        return _cachedCart;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Xóa item khỏi giỏ hàng
  Future<CartData?> removeFromCart(String cartItemId) async {
    try {
      final response = await _apiService.removeCartItem(cartItemId);
      
      if (response['success'] == true && response['data'] != null) {
        _cachedCart = CartData.fromMap(response['data']);
        return _cachedCart;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Xóa tất cả items trong giỏ hàng
  Future<bool> clearCart() async {
    try {
      final response = await _apiService.clearCart();
      
      if (response['success'] == true) {
        _cachedCart = CartData.empty();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Lấy tổng quan giỏ hàng
  Future<CartSummary> getCartSummary() async {
    final cart = await getCart();
    return CartSummary(
      items: cart.items,
      subtotal: cart.subtotal,
      shippingFee: cart.shippingFee,
      tax: cart.tax,
      total: cart.total,
    );
  }
}

/// Cart data từ API
class CartData {
  final List<CartModel> items;
  final int itemCount;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;

  CartData({
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
  });

  factory CartData.empty() {
    return CartData(
      items: [],
      itemCount: 0,
      subtotal: 0,
      shippingFee: 30000,
      tax: 0,
      total: 30000,
    );
  }

  factory CartData.fromMap(Map<String, dynamic> map) {
    final List<dynamic> itemsData = map['items'] ?? [];
    
    return CartData(
      items: itemsData.map((item) => CartModel.fromApiMap(item)).toList(),
      itemCount: map['itemCount'] ?? 0,
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 30000).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
    );
  }
}
