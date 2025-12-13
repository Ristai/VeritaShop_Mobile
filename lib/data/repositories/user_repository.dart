import '../models/user_model.dart';

/// Repository xử lý logic nghiệp vụ cho người dùng
class UserRepository {
  UserRepository();

  /// Đăng nhập
  Future<UserModel?> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Mock validation - trong thực tế sẽ gọi API
    if (email.isNotEmpty && password.length >= 6) {
      return UserModel(
        id: '1',
        name: email.split('@')[0],
        email: email,
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  /// Đăng ký
  Future<UserModel?> register(String name, String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock validation - trong thực tế sẽ gọi API
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      return UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
    }
    return null;
  }
}

