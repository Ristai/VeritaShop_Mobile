/// Model dữ liệu sản phẩm
class ProductModel {
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

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    this.isFeatured = false,
    required this.createdAt,
    this.tags = const [],
  });

  /// Kiểm tra sản phẩm còn hàng
  bool get isInStock => stock > 0;

  /// Kiểm tra sản phẩm sắp hết hàng (dưới 10)
  bool get isLowStock => stock > 0 && stock < 10;

  /// Kiểm tra sản phẩm hết hàng
  bool get isOutOfStock => stock == 0;

  /// Format giá tiền theo định dạng VNĐ
  String get formattedPrice {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M đ';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K đ';
    }
    return '${price.toStringAsFixed(0)} đ';
  }

  /// Tạo copy với các giá trị mới
  ProductModel copyWith({
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
    return ProductModel(
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

  /// Create ProductModel từ Map (để sử dụng với API responses)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['image_url'] ?? map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['review_count'] ?? map['reviewCount'] ?? 0,
      stock: map['stock'] ?? 0,
      isFeatured: map['is_featured'] ?? map['isFeatured'] ?? false,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

