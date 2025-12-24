import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

/// Interceptor xử lý authentication token
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor({FlutterSecureStorage? storage})
      : _storage = storage ?? getSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Các endpoint không cần token
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/products',
      '/reviews/product',
    ];

    final isPublic = publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublic) {
      final token = await _storage.read(key: 'access_token');
      if (kDebugMode) {
        print('AuthInterceptor: Token = ${token != null ? "exists (${token.length} chars)" : "null"}');
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
  final FlutterSecureStorage _storage;
  bool _isRefreshing = false;

  RefreshTokenInterceptor({
    required Dio dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio,
        _storage = storage ?? getSecureStorage();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final errorCode = err.response?.data?['error']?['code'];
      
      if (errorCode == 'TOKEN_EXPIRED' && !_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshToken = await _storage.read(key: 'refresh_token');
          
          if (refreshToken != null) {
            // Call refresh endpoint
            final response = await _dio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            if (response.data['success'] == true) {
              final newAccessToken = response.data['data']['accessToken'];
              final newRefreshToken = response.data['data']['refreshToken'];

              // Save new tokens
              await _storage.write(key: 'access_token', value: newAccessToken);
              await _storage.write(key: 'refresh_token', value: newRefreshToken);

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

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_email');
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
