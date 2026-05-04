import 'package:dio/dio.dart';
import 'api_client.dart';

/// Implementation cho ApiClient sử dụng Dio
class ApiClientImpl implements ApiClient {
  final Dio _dio;
  final String baseUrl;

  ApiClientImpl({required this.baseUrl, Dio? dio})
      : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Set authentication token cho các request
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReviews() async {
    try {
      final response = await _dio.get('/reviews');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReviewsByProductId(String productId) async {
    try {
      final response = await _dio.get('/reviews', queryParameters: {
        'product_id': productId,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingTopics() async {
    try {
      final response = await _dio.get('/analytics/trending-topics');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInsights() async {
    try {
      final response = await _dio.get('/analytics/insights');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic GET method
  @override
  Future<List<Map<String, dynamic>>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data['data'] is List) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic POST method
  @override
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      } else if (response.data is Map && response.data['data'] is Map) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      return {};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic PUT method
  @override
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      } else if (response.data is Map && response.data['data'] is Map) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      return {};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic DELETE method
  @override
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'success': true};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors và convert sang exception dễ xử lý hơn
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Request timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? e.message;
        
        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized: Please login again.');
          case 403:
            return Exception('Forbidden: You don\'t have permission to access this resource.');
          case 404:
            return Exception('Not found: The requested resource was not found.');
          case 500:
            return Exception('Server error: Please try again later.');
          default:
            return Exception('HTTP Error $statusCode: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('Connection error: Please check your internet connection.');
      case DioExceptionType.unknown:
        return Exception('An unexpected error occurred: ${e.message}');
      default:
        return Exception('An error occurred: ${e.message}');
    }
  }
}
