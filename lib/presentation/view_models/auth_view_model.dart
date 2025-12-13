import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  AuthViewModel({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final token = await _secureStorage.read(key: 'user_token');
      final userId = await _secureStorage.read(key: 'user_id');
      
      if (token != null && userId != null) {
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
      await Future.delayed(const Duration(seconds: 1));
      
      if (email.isNotEmpty && password.length >= 6) {
        _currentUser = UserModel(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@').first,
          email: email,
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
        );
        
        await _secureStorage.write(key: 'user_token', value: 'mock_jwt_token');
        await _secureStorage.write(key: 'user_id', value: _currentUser!.id);
        await _secureStorage.write(key: 'user_name', value: _currentUser!.name);
        await _secureStorage.write(key: 'user_email', value: _currentUser!.email);
        await _secureStorage.write(key: 'user_avatar', value: _currentUser!.avatarUrl);
        
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError('Email hoặc mật khẩu không hợp lệ');
        return false;
      }
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
      await Future.delayed(const Duration(seconds: 1));
      
      if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
        _currentUser = UserModel(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
        );
        
        await _secureStorage.write(key: 'user_token', value: 'mock_jwt_token');
        await _secureStorage.write(key: 'user_id', value: _currentUser!.id);
        await _secureStorage.write(key: 'user_name', value: _currentUser!.name);
        await _secureStorage.write(key: 'user_email', value: _currentUser!.email);
        await _secureStorage.write(key: 'user_avatar', value: _currentUser!.avatarUrl);
        
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError('Thông tin đăng ký không hợp lệ');
        return false;
      }
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
