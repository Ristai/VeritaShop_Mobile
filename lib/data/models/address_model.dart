class AddressModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String streetAddress;
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.streetAddress,
    this.isDefault = false,
    required this.createdAt,
  });

  String get fullAddress {
    return '$streetAddress, $ward, $district, $province';
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      fullName: map['full_name'] ?? '',
      phone: map['phone'] ?? '',
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      ward: map['ward'] ?? '',
      streetAddress: map['street_address'] ?? '',
      isDefault: map['is_default'] ?? false,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'province': province,
      'district': district,
      'ward': ward,
      'street_address': streetAddress,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? province,
    String? district,
    String? ward,
    String? streetAddress,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      streetAddress: streetAddress ?? this.streetAddress,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
