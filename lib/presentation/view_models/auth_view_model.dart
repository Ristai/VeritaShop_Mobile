import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

class AuthViewModel extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage;
  final ApiService _apiService;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  AuthViewModel({
    FlutterSecureStorage? secureStorage,
    ApiService? apiService,
  })  : _secureStorage = secureStorage ?? getSecureStorage(),
        _apiService = apiService ?? ApiService.instance;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final token = await _secureStorage.read(key: 'access_token');
      final userId = await _secureStorage.read(key: 'user_id');
      
      if (token != null && userId != null) {
        // Try to get user info from API
        try {
          final response = await _apiService.getMe();
          if (response['success'] == true) {
            final userData = response['data']['user'];
            _currentUser = UserModel(
              id: userData['id'],
              name: userData['name'],
              email: userData['email'],
              avatarUrl: userData['avatar'] ?? '',
            );
            _isAuthenticated = true;
          }
        } catch (e) {
          // Token might be expired, try to use stored data
          final userName = await _secureStorage.read(key: 'user_name') ?? '';
          final userEmail = await _secureStorage.read(key: 'user_email') ?? '';
          final userAvatar = await _secureStorage.read(key: 'user_avatar') ?? '';
          
          _currentUser = UserModel(
            id: userId,
            name: userName,
            email: userEmail,
            avatarUrl: userAvatar,
          );
          _isAuthenticated = true;
        }
      }
    } catch (e) {
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
        
        _currentUser = UserModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          avatarUrl: userData['avatar'] ?? '',
        );
        
        // Save tokens and user info
        await _secureStorage.write(key: 'access_token', value: accessToken);
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        await _secureStorage.write(key: 'user_id', value: _currentUser!.id);
        await _secureStorage.write(key: 'user_name', value: _currentUser!.name);
        await _secureStorage.write(key: 'user_email', value: _currentUser!.email);
        await _secureStorage.write(key: 'user_avatar', value: _currentUser!.avatarUrl);
        
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
        
        _currentUser = UserModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          avatarUrl: userData['avatar'] ?? '',
        );
        
        // Save tokens and user info
        await _secureStorage.write(key: 'access_token', value: accessToken);
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        await _secureStorage.write(key: 'user_id', value: _currentUser!.id);
        await _secureStorage.write(key: 'user_name', value: _currentUser!.name);
        await _secureStorage.write(key: 'user_email', value: _currentUser!.email);
        await _secureStorage.write(key: 'user_avatar', value: _currentUser!.avatarUrl);
        
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
      await _secureStorage.deleteAll();
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
