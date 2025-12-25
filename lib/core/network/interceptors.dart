import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Shared FlutterSecureStorage instance with web config
FlutterSecureStorage getSecureStorage() {
  return const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'VeritaShop',
      publicKey: 'VeritaShop',
    ),
  );
}

/// Helper to read token - prefers SharedPreferences on web
Future<String?> readToken(String key) async {
  debugPrint('readToken: Reading key=$key, isWeb=$kIsWeb');
  
  // On web, prefer SharedPreferences for reliability
  if (kIsWeb) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);
      debugPrint('readToken: SharedPreferences value=${value != null ? "exists (${value.length} chars)" : "null"}');
      if (value != null && value.isNotEmpty) return value;
    } catch (e) {
      debugPrint('readToken: SharedPreferences error: $e');
    }
  }
  
  // Fallback to secure storage
  try {
    final storage = getSecureStorage();
    final value = await storage.read(key: key);
    debugPrint('readToken: SecureStorage value=${value != null ? "exists" : "null"}');
    return value;
  } catch (e) {
    debugPrint('SecureStorage read failed: $e');
    return null;
  }
}

/// Interceptor xử lý authentication token
class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Các endpoint không cần token (exact match hoặc startsWith)
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
    ];

    // Các prefix không cần token
    final publicPrefixes = [
      '/products',  // GET /products, /products/:id
      '/reviews/product',
    ];

    // Kiểm tra xem có phải endpoint admin không (admin luôn cần auth)
    final isAdminEndpoint = options.path.startsWith('/admin');
    
    // Kiểm tra public endpoint
    final isPublicExact = publicEndpoints.any(
      (endpoint) => options.path == endpoint || options.path.startsWith('$endpoint?'),
    );
    
    final isPublicPrefix = !isAdminEndpoint && publicPrefixes.any(
      (prefix) => options.path.startsWith(prefix),
    );
    
    final isPublic = isPublicExact || isPublicPrefix;

    if (!isPublic) {
      final token = await readToken('access_token');
      if (kDebugMode) {
        print('AuthInterceptor: Path=${options.path}, Token=${token != null ? "exists" : "null"}');
      }
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }
}

/// Interceptor tự động refresh token khi hết hạn
class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  RefreshTokenInterceptor({
    required Dio dio,
  }) : _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final errorCode = err.response?.data?['error']?['code'];
      
      if (errorCode == 'TOKEN_EXPIRED' && !_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshToken = await readToken('refresh_token');
          
          if (refreshToken != null) {
            // Call refresh endpoint
            final response = await _dio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            if (response.data['success'] == true) {
              final newAccessToken = response.data['data']['accessToken'];
              final newRefreshToken = response.data['data']['refreshToken'];

              // Save new tokens using SharedPreferences on web
              await _saveToken('access_token', newAccessToken);
              await _saveToken('refresh_token', newRefreshToken);

              // Retry original request
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await _dio.fetch(opts);
              _isRefreshing = false;
              return handler.resolve(retryResponse);
            }
          }

          // Refresh failed, clear tokens
          await _clearTokens();
        } catch (e) {
          await _clearTokens();
        }

        _isRefreshing = false;
      }
    }

    handler.next(err);
  }
  
  Future<void> _saveToken(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
    try {
      final storage = getSecureStorage();
      await storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('SecureStorage write failed: $e');
    }
  }

  Future<void> _clearTokens() async {
    final keys = ['access_token', 'refresh_token', 'user_id', 'user_name', 'user_email'];
    
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      for (final key in keys) {
        await prefs.remove(key);
      }
    }
    
    try {
      final storage = getSecureStorage();
      for (final key in keys) {
        await storage.delete(key: key);
      }
    } catch (e) {
      debugPrint('SecureStorage delete failed: $e');
    }
  }
}

/// Interceptor xử lý lỗi và log
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    String code = 'UNKNOWN_ERROR';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Kết nối timeout. Vui lòng thử lại.';
        code = 'TIMEOUT';
        break;
      case DioExceptionType.connectionError:
        message = 'Không có kết nối mạng.';
        code = 'NO_CONNECTION';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        
        if (responseData is Map) {
          message = responseData['error']?['message'] ?? 
                   responseData['message'] ?? 
                   'Lỗi không xác định';
          code = responseData['error']?['code'] ?? 'HTTP_$statusCode';
        } else {
          message = _getMessageForStatusCode(statusCode);
          code = 'HTTP_$statusCode';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Yêu cầu đã bị hủy.';
        code = 'CANCELLED';
        break;
      default:
        message = 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }

    // Create custom exception with Vietnamese message
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: ApiError(message: message, code: code),
    );

    handler.next(customError);
  }

  String _getMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Dữ liệu không hợp lệ.';
      case 401:
        return 'Phiên đăng nhập đã hết hạn.';
      case 403:
        return 'Bạn không có quyền truy cập.';
      case 404:
        return 'Không tìm thấy dữ liệu.';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau.';
      default:
        return 'Đã xảy ra lỗi.';
    }
  }
}

/// Custom API Error class
class ApiError {
  final String message;
  final String code;

  ApiError({required this.message, required this.code});

  @override
  String toString() => message;
}
