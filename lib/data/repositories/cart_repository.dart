import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../data_sources/local/mock_data_source.dart';
import '../data_sources/remote/api_client.dart';

/// Repository xử lý logic nghiệp vụ cho giỏ hàng
class CartRepository {
  final ApiClient? _apiClient;
  final MockDataSource? _mockDataSource;
  final FlutterSecureStorage _secureStorage;
  
  // Cache for cart items (để tránh gọi API liên tục)
  List<CartModel> _cachedItems = [];
  
  CartRepository({
    ApiClient? apiClient,
    MockDataSource? mockDataSource,
    FlutterSecureStorage? secureStorage,
  }) : _apiClient = apiClient,
       _mockDataSource = mockDataSource ?? MockDataSource(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Lấy tất cả items trong giỏ hàng của user
  Future<List<CartModel>> getCartItems() async {
    try {
      // Trong môi trường production, sẽ gọi API
      if (_apiClient != null) {
        final userId = await _getCurrentUserId();
        if (userId.isEmpty) return [];
        
        final response = await _apiClient.get('/carts/$userId');
        final items = List<CartModel>.from(
          response.map((item) => CartModel.fromMap(item))
        );
        _cachedItems = items;
        return items;
      }
      
      // Mock data cho môi trường development
      final mockItems = await _getMockCartItems();
      _cachedItems = mockItems;
      return mockItems;
    } catch (e) {
      // Trả về cache nếu có lỗi
      return _cachedItems;
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<bool> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      // Lấy thông tin sản phẩm
      final product = await _getProductById(productId);
      if (product == null) return false;
      
      // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
      final existingItem = _findCartItemByProductId(productId);
      
      if (existingItem != null) {
        // Nếu đã có, tăng số lượng
        return await updateCartItem(
          existingItem.id,
          existingItem.quantity + quantity,
        );
      } else {
        // Nếu chưa có, tạo item mới
        final userId = await _getCurrentUserId();
        final newCartItem = CartModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          productId: productId,
          productName: product.name,
          productImageUrl: product.imageUrl,
          price: product.price,
          quantity: quantity,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Trong môi trường production, sẽ gọi API
        if (_apiClient != null) {
          await _apiClient.post('/carts', data: newCartItem.toMap());
        }
        
        // Cập nhật cache
        _cachedItems.add(newCartItem);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  /// Cập nhật số lượng item trong giỏ hàng
  Future<bool> updateCartItem(String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        return await removeFromCart(cartItemId);
      }
      
      // Tìm item trong cache
      final itemIndex = _cachedItems.indexWhere((item) => item.id == cartItemId);
      if (itemIndex == -1) return false;
      
      // Cập nhật số lượng
      _cachedItems[itemIndex] = _cachedItems[itemIndex].copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      
      // Trong môi trường production, sẽ gọi API
      if (_apiClient != null) {
        await _apiClient.put('/carts/$cartItemId', data: {
          'quantity': newQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Xóa item khỏi giỏ hàng
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      // Xóa khỏi cache
      _cachedItems.removeWhere((item) => item.id == cartItemId);
      
      // Trong môi trường production, sẽ gọi API
      if (_apiClient != null) {
        await _apiClient.delete('/carts/$cartItemId');
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Xóa tất cả items trong giỏ hàng
  Future<bool> clearCart() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId.isEmpty) return false;
      
      // Xóa cache
      _cachedItems.clear();
      
      // Trong môi trường production, sẽ gọi API
      if (_apiClient != null) {
        await _apiClient.delete('/carts/$userId');
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Lấy tổng quan giỏ hàng
  Future<CartSummary> getCartSummary() async {
    final items = await getCartItems();
    return CartSummary.fromItems(items);
  }

  // Helper methods

  /// Lấy current user ID từ secure storage
  Future<String> _getCurrentUserId() async {
    return await _secureStorage.read(key: 'user_id') ?? 'demo_user';
  }

  /// Lấy sản phẩm theo ID
  Future<ProductModel?> _getProductById(String productId) async {
    if (_mockDataSource != null) {
      return await _mockDataSource.getProductById(productId);
    }
    
    // Trong môi trường production, sẽ gọi API
    if (_apiClient != null) {
      try {
        final response = await _apiClient.getProductById(productId);
        return ProductModel.fromMap(response);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  /// Tìm cart item theo product ID (trong cache)
  CartModel? _findCartItemByProductId(String productId) {
    try {
      return _cachedItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Mock cart items cho demo
  Future<List<CartModel>> _getMockCartItems() async {
    // Lấy mock products
    final products = await _mockDataSource!.getProducts();
    final userId = await _getCurrentUserId();
    
    // Tạo mock cart items từ 2 sản phẩm đầu tiên
    if (products.isNotEmpty) {
      final firstItem = CartModel(
        id: 'cart_1',
        userId: userId,
        productId: products[0].id,
        productName: products[0].name,
        productImageUrl: products[0].imageUrl,
        price: products[0].price,
        quantity: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      
      if (products.length > 1) {
        final secondItem = CartModel(
          id: 'cart_2',
          userId: userId,
          productId: products[1].id,
          productName: products[1].name,
          productImageUrl: products[1].imageUrl,
          price: products[1].price,
          quantity: 1,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        
        return [firstItem, secondItem];
      }
      
      return [firstItem];
    }
    
    return [];
  }
}
