import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'interceptors.dart';

/// Singleton API Service với Dio và interceptors
class ApiService {
  static ApiService? _instance;
  late final Dio dio;

  ApiService._() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
    
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(),
      RefreshTokenInterceptor(dio: dio),
      ErrorInterceptor(),
      // Log interceptor for debug
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('API: $obj'),
      ),
    ]);
  }

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await dio.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    return response.data;
  }

  Future<void> logout() async {
    await dio.post('/auth/logout');
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await dio.get('/auth/me');
    return response.data;
  }

  // Products endpoints
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? brand,
    String? sort,
    int? minPrice,
    int? maxPrice,
    String? ram,
    String? rom,
    String? condition,
    String? search,
    bool? featured,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (brand != null) queryParams['brand'] = brand;
    if (sort != null) queryParams['sort'] = sort;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (ram != null) queryParams['ram'] = ram;
    if (rom != null) queryParams['rom'] = rom;
    if (condition != null) queryParams['condition'] = condition;
    if (search != null) queryParams['search'] = search;
    if (featured != null) queryParams['featured'] = featured;

    final response = await dio.get('/products', queryParameters: queryParams);
    return response.data;
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await dio.get('/products/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> searchProducts(String query, {int page = 1}) async {
    final response = await dio.get('/products/search', queryParameters: {
      'q': query,
      'page': page,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getProductsByBrand(String brand, {int page = 1}) async {
    final response = await dio.get('/products/brand/$brand', queryParameters: {
      'page': page,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getBrands() async {
    final response = await dio.get('/products/brands');
    return response.data;
  }

  Future<Map<String, dynamic>> getFeaturedProducts({int limit = 10}) async {
    final response = await dio.get('/products/featured', queryParameters: {
      'limit': limit,
    });
    return response.data;
  }

  // Cart endpoints
  Future<Map<String, dynamic>> getCart() async {
    final response = await dio.get('/cart');
    return response.data;
  }

  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
    required Map<String, dynamic> color,
  }) async {
    final response = await dio.post('/cart', data: {
      'productId': productId,
      'quantity': quantity,
      'color': color,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateCartItem(String itemId, int quantity) async {
    final response = await dio.put('/cart/$itemId', data: {
      'quantity': quantity,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> removeCartItem(String itemId) async {
    final response = await dio.delete('/cart/$itemId');
    return response.data;
  }

  Future<Map<String, dynamic>> clearCart() async {
    final response = await dio.delete('/cart');
    return response.data;
  }

  // Orders endpoints
  Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? note,
    String? couponCode,
  }) async {
    final response = await dio.post('/orders', data: {
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      if (note != null) 'note': note,
      if (couponCode != null) 'couponCode': couponCode,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getOrders({int page = 1, String? status}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (status != null) queryParams['status'] = status;
    
    final response = await dio.get('/orders', queryParameters: queryParams);
    return response.data;
  }

  Future<Map<String, dynamic>> getOrderById(String id) async {
    final response = await dio.get('/orders/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> cancelOrder(String id, {String? reason}) async {
    final response = await dio.put('/orders/$id/cancel', data: {
      if (reason != null) 'reason': reason,
    });
    return response.data;
  }

  // Reviews endpoints
  Future<Map<String, dynamic>> getProductReviews(String productId, {
    int page = 1,
    String sort = 'newest',
    int? rating,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'sort': sort,
    };
    if (rating != null) queryParams['rating'] = rating;

    final response = await dio.get('/reviews/product/$productId', queryParameters: queryParams);
    return response.data;
  }

  Future<Map<String, dynamic>> createReview({
    required String productId,
    required int rating,
    required String text,
    String? title,
    List<String>? images,
  }) async {
    final response = await dio.post('/reviews', data: {
      'productId': productId,
      'rating': rating,
      'text': text,
      if (title != null) 'title': title,
      if (images != null) 'images': images,
    });
    return response.data;
  }

  // User endpoints
  Future<Map<String, dynamic>> getProfile() async {
    final response = await dio.get('/users/profile');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    final response = await dio.put('/users/profile', data: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar': avatar,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> address) async {
    final response = await dio.post('/users/addresses', data: address);
    return response.data;
  }

  Future<Map<String, dynamic>> updateAddress(String addressId, Map<String, dynamic> address) async {
    final response = await dio.put('/users/addresses/$addressId', data: address);
    return response.data;
  }

  Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    final response = await dio.delete('/users/addresses/$addressId');
    return response.data;
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final response = await dio.put('/users/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return response.data;
  }

  // Related Products
  Future<Map<String, dynamic>> getRelatedProducts(String productId, {int limit = 4}) async {
    final response = await dio.get('/products/$productId/related', queryParameters: {
      'limit': limit,
    });
    return response.data;
  }

  // Order - Get by order number
  Future<Map<String, dynamic>> getOrderByNumber(String orderNumber) async {
    final response = await dio.get('/orders/number/$orderNumber');
    return response.data;
  }

  // Order - Reorder
  Future<Map<String, dynamic>> reorder(String orderId) async {
    final response = await dio.post('/orders/$orderId/reorder');
    return response.data;
  }

  // Reviews - Get my reviews
  Future<Map<String, dynamic>> getMyReviews({int page = 1}) async {
    final response = await dio.get('/reviews/my-reviews', queryParameters: {
      'page': page,
    });
    return response.data;
  }

  // Reviews - Update
  Future<Map<String, dynamic>> updateReview(String reviewId, {
    int? rating,
    String? text,
    String? title,
  }) async {
    final response = await dio.put('/reviews/$reviewId', data: {
      if (rating != null) 'rating': rating,
      if (text != null) 'text': text,
      if (title != null) 'title': title,
    });
    return response.data;
  }

  // Reviews - Delete
  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    final response = await dio.delete('/reviews/$reviewId');
    return response.data;
  }

  // Reviews - Like
  Future<Map<String, dynamic>> likeReview(String reviewId) async {
    final response = await dio.post('/reviews/$reviewId/like');
    return response.data;
  }

  // Upload - Single image
  Future<Map<String, dynamic>> uploadImage(List<int> imageBytes, String filename) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(imageBytes, filename: filename),
    });
    final response = await dio.post('/upload/image', data: formData);
    return response.data;
  }

  // Upload - Multiple images
  Future<Map<String, dynamic>> uploadImages(List<Map<String, dynamic>> images) async {
    final formData = FormData();
    for (var img in images) {
      formData.files.add(MapEntry(
        'images',
        MultipartFile.fromBytes(img['bytes'], filename: img['filename']),
      ));
    }
    final response = await dio.post('/upload/images', data: formData);
    return response.data;
  }

  // Upload - Avatar
  Future<Map<String, dynamic>> uploadAvatar(List<int> imageBytes, String filename) async {
    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(imageBytes, filename: filename),
    });
    final response = await dio.post('/upload/avatar', data: formData);
    return response.data;
  }

  // Upload - Delete image
  Future<Map<String, dynamic>> deleteImage(String publicId) async {
    final response = await dio.delete('/upload/image/$publicId');
    return response.data;
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await dio.post('/auth/forgot-password', data: {
      'email': email,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    final response = await dio.post('/auth/verify-reset-code', data: {
      'email': email,
      'code': code,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) async {
    final response = await dio.post('/auth/reset-password', data: {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
    return response.data;
  }

  // Coupons
  Future<Map<String, dynamic>> getCoupons() async {
    final response = await dio.get('/coupons');
    return response.data;
  }

  Future<Map<String, dynamic>> applyCoupon(String code, double orderAmount) async {
    final response = await dio.post('/coupons/apply', data: {
      'code': code,
      'orderAmount': orderAmount,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getCouponByCode(String code) async {
    final response = await dio.get('/coupons/$code');
    return response.data;
  }
}
