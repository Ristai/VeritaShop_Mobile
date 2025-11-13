import 'package:flutter/material.dart';

/// Model dữ liệu cho Product (Sản phẩm)
/// Chứa tất cả thông tin cần thiết để hiển thị và quản lý sản phẩm
class ProductViewModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFeatured;
  final DateTime createdAt;
  final List<String> tags;

  ProductViewModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.stock,
    this.isFeatured = false,
    required this.createdAt,
    this.tags = const [],
  });

  /// Factory constructor để tạo product từ JSON
  factory ProductViewModel.fromJson(Map<String, dynamic> json) {
    return ProductViewModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      stock: json['stock'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  /// Chuyển đổi product thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  /// Copy product với một số thuộc tính được thay đổi
  ProductViewModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    double? rating,
    int? reviewCount,
    int? stock,
    bool? isFeatured,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return ProductViewModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  /// Kiểm tra xem sản phẩm có còn hàng không
  bool get isInStock => stock > 0;

  /// Kiểm tra xem sản phẩm có sắp hết hàng không (còn < 10)
  bool get isLowStock => stock > 0 && stock < 10;

  /// Kiểm tra xem sản phẩm có hết hàng không
  bool get isOutOfStock => stock <= 0;

  /// Lấy màu status dựa trên số lượng tồn kho
  Color get stockStatusColor {
    if (isOutOfStock) return Colors.red;
    if (isLowStock) return Colors.orange;
    return Colors.green;
  }

  /// Lấy text status về tồn kho
  String get stockStatusText {
    if (isOutOfStock) return 'Hết hàng';
    if (isLowStock) return 'Sắp hết ($stock còn lại)';
    return 'Còn hàng ($stock)';
  }

  /// Format giá tiền theo định dạng VND
  String get formattedPrice {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}₫';
  }

  /// Lấy rating dưới dạng icon
  String get ratingDisplay => '$rating ⭐ ($reviewCount)';
}
