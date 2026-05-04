import '../models/product_model.dart';
import '../../core/network/api_service.dart';

class AdminRepository {
  final ApiService _api = ApiService.instance;

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _api.getAdminDashboard();
    return response['data'] ?? {};
  }

  // Products
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? brand,
    String sort = '-createdAt',
  }) async {
    final response = await _api.getAdminProducts(
      page: page,
      limit: limit,
      search: search,
      brand: brand,
      sort: sort,
    );
    return {
      'products': (response['data']?['products'] as List?)
          ?.map((p) => ProductModel.fromMap(p))
          .toList() ?? [],
      'pagination': response['data']?['pagination'],
    };
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await _api.createAdminProduct(data);
    return ProductModel.fromMap(response['data']['product']);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _api.updateAdminProduct(id, data);
    return ProductModel.fromMap(response['data']['product']);
  }

  Future<void> deleteProduct(String id) async {
    await _api.deleteAdminProduct(id);
  }

  // Orders
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String sort = '-createdAt',
  }) async {
    final response = await _api.getAdminOrders(
      page: page,
      limit: limit,
      status: status,
      sort: sort,
    );
    return {
      'orders': response['data']?['orders'] ?? [],
      'pagination': response['data']?['pagination'],
    };
  }

  Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    final response = await _api.updateAdminOrderStatus(id, status);
    return response['data']?['order'] ?? {};
  }

  Future<void> refundOrder(String id) async {
    await _api.refundAdminOrder(id);
  }

  // Users
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String sort = '-createdAt',
  }) async {
    final response = await _api.getAdminUsers(
      page: page,
      limit: limit,
      search: search,
      sort: sort,
    );
    return {
      'users': response['data']?['users'] ?? [],
      'pagination': response['data']?['pagination'],
    };
  }

  Future<Map<String, dynamic>> toggleUserStatus(String id) async {
    final response = await _api.updateAdminUserStatus(id);
    return response['data']?['user'] ?? {};
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await _api.createAdminUser(data);
    return response['data']?['user'] ?? {};
  }

  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _api.updateAdminUser(id, data);
    return response['data']?['user'] ?? {};
  }

  Future<void> deleteUser(String id) async {
    await _api.deleteAdminUser(id);
  }

  Future<String> resetUserPassword(String id) async {
    final response = await _api.resetAdminUserPassword(id);
    return response['data']?['email'] ?? '';
  }

  // Carts
  Future<Map<String, dynamic>> getCarts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _api.getAdminCarts(
      page: page,
      limit: limit,
      search: search,
    );
    return {
      'carts': response['data']?['carts'] ?? [],
      'pagination': response['data']?['pagination'],
    };
  }

  Future<Map<String, dynamic>> getCartByUser(String userId) async {
    final response = await _api.getAdminCartByUser(userId);
    return response['data']?['cart'] ?? {};
  }

  Future<void> updateCartItem(String userId, String itemId, int quantity) async {
    await _api.updateAdminCartItem(userId, itemId, quantity);
  }

  Future<void> deleteCartItem(String userId, String itemId) async {
    await _api.deleteAdminCartItem(userId, itemId);
  }

  Future<void> clearUserCart(String userId) async {
    await _api.clearAdminUserCart(userId);
  }

  // Coupons
  Future<List<Map<String, dynamic>>> getCoupons() async {
    final response = await _api.getAdminCoupons();
    return List<Map<String, dynamic>>.from(response['data']?['coupons'] ?? []);
  }

  Future<Map<String, dynamic>> createCoupon(Map<String, dynamic> data) async {
    final response = await _api.createAdminCoupon(data);
    return response['data']?['coupon'] ?? {};
  }

  Future<Map<String, dynamic>> updateCoupon(String id, Map<String, dynamic> data) async {
    final response = await _api.updateAdminCoupon(id, data);
    return response['data']?['coupon'] ?? {};
  }

  Future<void> deleteCoupon(String id) async {
    await _api.deleteAdminCoupon(id);
  }

  // Reviews
  Future<Map<String, dynamic>> getReviews({
    int page = 1,
    int limit = 20,
    String? status,
    bool? flagged,
    String sort = '-createdAt',
  }) async {
    final response = await _api.getAdminReviews(
      page: page,
      limit: limit,
      status: status,
      flagged: flagged,
      sort: sort,
    );
    return {
      'reviews': response['data']?['reviews'] ?? [],
      'pagination': response['data']?['pagination'],
      'flaggedCount': response['data']?['flaggedCount'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> getFlaggedReviews({
    int page = 1,
    int limit = 20,
    String sort = '-createdAt',
  }) async {
    final response = await _api.getAdminFlaggedReviews(
      page: page,
      limit: limit,
      sort: sort,
    );
    return {
      'reviews': response['data']?['reviews'] ?? [],
      'pagination': response['data']?['pagination'],
    };
  }

  Future<void> approveReview(String id) async {
    await _api.approveAdminReview(id);
  }

  Future<Map<String, dynamic>> approveReviewModeration(String id, {String? note}) async {
    final response = await _api.approveAdminReviewModeration(id, note: note);
    return response['data']?['review'] ?? {};
  }

  Future<Map<String, dynamic>> rejectReviewModeration(String id, {String? note}) async {
    final response = await _api.rejectAdminReviewModeration(id, note: note);
    return response['data']?['review'] ?? {};
  }

  Future<void> deleteReview(String id) async {
    await _api.deleteAdminReview(id);
  }

  Future<Map<String, String>> getModerationCategories() async {
    final response = await _api.getModerationCategories();
    final categories = response['data']?['categories'] ?? {};
    return Map<String, String>.from(categories);
  }

  // Reports
  Future<Map<String, dynamic>> getRevenueReport({
    String? from,
    String? to,
    String groupBy = 'day',
  }) async {
    final response = await _api.getAdminRevenueReport(
      from: from,
      to: to,
      groupBy: groupBy,
    );
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> getProductReport() async {
    final response = await _api.getAdminProductReport();
    return response['data'] ?? {};
  }

  Future<Map<String, dynamic>> getOrderReport() async {
    final response = await _api.getAdminOrderReport();
    return response['data'] ?? {};
  }
}
