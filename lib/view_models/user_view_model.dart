/// Model dữ liệu cho User (Người dùng)
/// Chứa thông tin cơ bản của một tài khoản người dùng
class UserViewModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final String? phoneNumber;
  final String role; // 'user' hoặc 'admin'

  UserViewModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    this.phoneNumber,
    this.role = 'user',
  });

  /// Factory constructor để tạo user từ JSON (chuẩn bị cho API integration)
  factory UserViewModel.fromJson(Map<String, dynamic> json) {
    return UserViewModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'user',
    );
  }

  /// Chuyển đổi user thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }

  /// Copy user với một số thuộc tính được thay đổi
  UserViewModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    String? phoneNumber,
    String? role,
  }) {
    return UserViewModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }

  /// Kiểm tra xem user có phải là admin không
  bool get isAdmin => role == 'admin';

  /// Lấy chữ cái đầu của tên để hiển thị avatar
  String get initials {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
