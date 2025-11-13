/// Abstract class cho API client
/// Implement này khi có API thật
abstract class ApiClient {
  // Product endpoints
  Future<List<Map<String, dynamic>>> getProducts();
  Future<Map<String, dynamic>> getProductById(String id);
  
  // Review endpoints
  Future<List<Map<String, dynamic>>> getReviews();
  Future<List<Map<String, dynamic>>> getReviewsByProductId(String productId);
  
  // User endpoints
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  
  // Trending topics endpoints
  Future<List<Map<String, dynamic>>> getTrendingTopics();
  
  // Insights endpoints
  Future<List<Map<String, dynamic>>> getInsights();
}

