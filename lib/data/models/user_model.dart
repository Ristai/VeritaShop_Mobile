/// Model dữ liệu người dùng
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role = 'customer',
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  /// Tạo copy với các giá trị mới
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatar'],
      role: map['role'] ?? 'customer',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
    );
  }
}

