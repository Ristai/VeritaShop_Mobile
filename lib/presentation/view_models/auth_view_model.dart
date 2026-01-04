import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_service.dart';
import '../../data/models/user_model.dart';

/// Shared FlutterSecureStorage instance with web config
FlutterSecureStorage getSecureStorage() {
  return const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'VeritaShop',
      publicKey: 'VeritaShop',
    ),
  );
}

/// Hybrid storage that uses SharedPreferences as fallback on web
class HybridStorage {
  final FlutterSecureStorage _secureStorage = getSecureStorage();
  SharedPreferences? _prefs;
  
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      await delete(key: key);
      return;
    }
    
    // Always write to SharedPreferences on web for reliability
    if (kIsWeb) {
      final p = await prefs;
      await p.setString(key, value);
    }
    
    // Also write to secure storage
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('SecureStorage write failed: $e');
    }
  }
  
  Future<String?> read({required String key}) async {
    // On web, prefer SharedPreferences
    if (kIsWeb) {
      final p = await prefs;
      final value = p.getString(key);
      if (value != null) return value;
    }
    
    // Fallback to secure storage
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('SecureStorage read failed: $e');
      return null;
    }
  }
  
  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      final p = await prefs;
      await p.remove(key);
    }
    
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('SecureStorage delete failed: $e');
    }
  }
  
  Future<void> deleteAll() async {
    // Auth keys - chỉ xóa thông tin đăng nhập
    final authKeys = ['access_token', 'refresh_token', 'user_id', 'user_name', 'user_email', 'user_avatar', 'user_role'];
    for (final key in authKeys) {
      await delete(key: key);
    }

    // KHÔNG xóa PIN keys khi logout - PIN được giữ lại theo device
    // User cần nhập lại PIN khi login lại
  }
}

class AuthViewModel extends ChangeNotifier {
  final HybridStorage _storage;
  final ApiService _apiService;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  AuthViewModel({
    HybridStorage? storage,
    ApiService? apiService,
  })  : _storage = storage ?? HybridStorage(),
        _apiService = apiService ?? ApiService.instance;

  UserModel? get currentUser => _currentUser;
  UserModel? get user => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final token = await _storage.read(key: 'access_token');
      final userId = await _storage.read(key: 'user_id');
      
      debugPrint('AuthViewModel.checkAuthStatus: token=${token != null}, userId=$userId');
      
      if (token != null && userId != null) {
        // Try to get user info from API
        try {
          final response = await _apiService.getMe();
          if (response['success'] == true) {
            final userData = response['data']['user'];
            _currentUser = UserModel.fromMap(userData);
            _isAuthenticated = true;
            debugPrint('AuthViewModel: Authenticated as ${_currentUser?.name}');
          }
        } catch (e) {
          debugPrint('AuthViewModel: getMe failed, using stored data: $e');
          // Token might be expired, try to use stored data
          final userName = await _storage.read(key: 'user_name') ?? '';
          final userEmail = await _storage.read(key: 'user_email') ?? '';
          final userAvatar = await _storage.read(key: 'user_avatar') ?? '';
          final userRole = await _storage.read(key: 'user_role') ?? 'customer';
          
          _currentUser = UserModel(
            id: userId,
            name: userName,
            email: userEmail,
            avatarUrl: userAvatar,
            role: userRole,
          );
          _isAuthenticated = true;
        }
      } else {
        debugPrint('AuthViewModel: No token or userId found');
      }
    } catch (e) {
      debugPrint('AuthViewModel.checkAuthStatus error: $e');
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.login(email, password);
      
      if (response['success'] == true) {
        final data = response['data'];
        final userData = data['user'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        
        _currentUser = UserModel.fromMap(userData);
        
        // Save tokens and user info
        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);
        await _storage.write(key: 'user_id', value: _currentUser!.id);
        await _storage.write(key: 'user_name', value: _currentUser!.name);
        await _storage.write(key: 'user_email', value: _currentUser!.email);
        await _storage.write(key: 'user_avatar', value: _currentUser!.avatarUrl ?? '');
        await _storage.write(key: 'user_role', value: _currentUser!.role);
        
        debugPrint('AuthViewModel: Login successful, saved user ${_currentUser!.id}');
        
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError(response['error']?['message'] ?? 'Đăng nhập thất bại');
        return false;
      }
    } on DioException catch (e) {
      final error = e.error;
      _setError(error?.toString() ?? 'Đăng nhập thất bại');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.register(name, email, password);
      
      if (response['success'] == true) {
        final data = response['data'];
        final userData = data['user'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        
        _currentUser = UserModel.fromMap(userData);
        
        // Save tokens and user info
        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);
        await _storage.write(key: 'user_id', value: _currentUser!.id);
        await _storage.write(key: 'user_name', value: _currentUser!.name);
        await _storage.write(key: 'user_email', value: _currentUser!.email);
        await _storage.write(key: 'user_avatar', value: _currentUser!.avatarUrl ?? '');
        await _storage.write(key: 'user_role', value: _currentUser!.role);
        
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError(response['error']?['message'] ?? 'Đăng ký thất bại');
        return false;
      }
    } on DioException catch (e) {
      final error = e.error;
      _setError(error?.toString() ?? 'Đăng ký thất bại');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      // Call logout API
      try {
        await _apiService.logout();
      } catch (e) {
        // Ignore logout API errors
      }
      
      // Clear all stored data
      await _storage.deleteAll();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
