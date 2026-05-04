/// Model dữ liệu sản phẩm điện thoại
import 'package:intl/intl.dart';

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String> images;
  final String category;
  final ProductSpecs specs;
  final List<ProductColor> colors;
  final String condition;
  final String warranty;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFeatured;
  final DateTime createdAt;
  final List<String> tags;

  ProductModel({
    required this.id,
    required this.name,
    this.brand = '',
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.images = const [],
    required this.category,
    ProductSpecs? specs,
    this.colors = const [],
    this.condition = 'new',
    this.warranty = '12 tháng',
    required this.rating,
    required this.reviewCount,
    required this.stock,
    this.isFeatured = false,
    required this.createdAt,
    this.tags = const [],
  }) : specs = specs ?? ProductSpecs.empty();

  /// Kiểm tra sản phẩm còn hàng
  bool get isInStock => stock > 0;

  /// Kiểm tra sản phẩm sắp hết hàng (dưới 10)
  bool get isLowStock => stock > 0 && stock < 10;

  /// Kiểm tra sản phẩm hết hàng
  bool get isOutOfStock => stock == 0;

  /// Tính % giảm giá
  int get discountPercent {
    if (originalPrice != null && originalPrice! > price) {
      return ((1 - price / originalPrice!) * 100).round();
    }
    return 0;
  }

  /// Format giá tiền theo định dạng VNĐ
  String get formattedPrice {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price.round())} VND';
  }

  /// Format giá gốc
  String get formattedOriginalPrice {
    if (originalPrice == null) return '';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(originalPrice!.round())} VND';
  }

  /// Tạo copy với các giá trị mới
  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    List<String>? images,
    String? category,
    ProductSpecs? specs,
    List<ProductColor>? colors,
    String? condition,
    String? warranty,
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
      brand: brand ?? this.brand,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      category: category ?? this.category,
      specs: specs ?? this.specs,
      colors: colors ?? this.colors,
      condition: condition ?? this.condition,
      warranty: warranty ?? this.warranty,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  /// Create ProductModel từ API response
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final imagesList = map['images'] as List<dynamic>? ?? [];
    final colorsList = map['colors'] as List<dynamic>? ?? [];
    final specsMap = map['specs'] as Map<String, dynamic>?;
    
    return ProductModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? map['category'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice']?.toDouble(),
      imageUrl: imagesList.isNotEmpty 
          ? imagesList[0] 
          : (map['image_url'] ?? map['imageUrl'] ?? ''),
      images: imagesList.map((e) => e.toString()).toList(),
      category: map['brand'] ?? map['category'] ?? '',
      specs: specsMap != null ? ProductSpecs.fromMap(specsMap) : ProductSpecs.empty(),
      colors: colorsList.map((c) => ProductColor.fromMap(c)).toList(),
      condition: map['condition'] ?? 'new',
      warranty: map['warranty'] ?? '12 tháng',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? map['review_count'] ?? 0,
      stock: map['stock'] ?? 0,
      isFeatured: map['isFeatured'] ?? map['is_featured'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : (map['created_at'] != null 
              ? DateTime.parse(map['created_at']) 
              : DateTime.now()),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

/// Thông số kỹ thuật điện thoại
class ProductSpecs {
  final String ram;
  final String rom;
  final String chip;
  final String battery;
  final String screen;
  final String camera;

  ProductSpecs({
    required this.ram,
    required this.rom,
    required this.chip,
    required this.battery,
    required this.screen,
    required this.camera,
  });

  factory ProductSpecs.empty() {
    return ProductSpecs(
      ram: '',
      rom: '',
      chip: '',
      battery: '',
      screen: '',
      camera: '',
    );
  }

  factory ProductSpecs.fromMap(Map<String, dynamic> map) {
    return ProductSpecs(
      ram: map['ram'] ?? '',
      rom: map['rom'] ?? '',
      chip: map['chip'] ?? '',
      battery: map['battery'] ?? '',
      screen: map['screen'] ?? '',
      camera: map['camera'] ?? '',
    );
  }
}

/// Màu sắc sản phẩm
class ProductColor {
  final String name;
  final String? code;
  final String? image;

  ProductColor({
    required this.name,
    this.code,
    this.image,
  });

  factory ProductColor.fromMap(Map<String, dynamic> map) {
    return ProductColor(
      name: map['name'] ?? '',
      code: map['code'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'code': code,
    'image': image,
  };
}
