class CartModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String productBrand;
  final String productImageUrl;
  final double price;
  final double? originalPrice;
  final int quantity;
  final CartColor color;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productBrand = '',
    required this.productImageUrl,
    required this.price,
    this.originalPrice,
    required this.quantity,
    required this.color,
    this.stock = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create CartModel từ Map (legacy)
  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      productBrand: map['product_brand'] ?? '',
      productImageUrl: map['product_image_url'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['original_price']?.toDouble(),
      quantity: map['quantity'] ?? 1,
      color: CartColor(name: map['color_name'] ?? '', code: map['color_code']),
      stock: map['stock'] ?? 0,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Create CartModel từ API response
  factory CartModel.fromApiMap(Map<String, dynamic> map) {
    // Handle both cart item format and order item format
    final product = map['product'];
    final colorData = map['color'] as Map<String, dynamic>? ?? {};
    
    // If product is a Map (cart item), extract from it
    // If product is a String (order item), use direct fields
    String productId;
    String productName;
    String productBrand;
    String productImageUrl;
    double price;
    double? originalPrice;
    int stock;
    
    if (product is Map<String, dynamic>) {
      // Cart item format: has nested product object
      final images = product['images'] as List<dynamic>? ?? [];
      productId = (product['_id'] ?? product['id'] ?? '').toString();
      productName = (product['name'] ?? '').toString();
      productBrand = (product['brand'] ?? '').toString();
      productImageUrl = images.isNotEmpty ? images[0].toString() : '';
      price = _toDouble(map['price'] ?? product['price']);
      originalPrice = _toDoubleOrNull(product['originalPrice']);
      stock = _toInt(product['stock']);
    } else {
      // Order item format: direct fields
      productId = (product ?? map['productId'] ?? '').toString();
      productName = (map['name'] ?? '').toString();
      productBrand = (map['brand'] ?? '').toString();
      productImageUrl = (map['image'] ?? '').toString();
      price = _toDouble(map['price']);
      originalPrice = null;
      stock = 0;
    }
    
    return CartModel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      userId: '',
      productId: productId,
      productName: productName,
      productBrand: productBrand,
      productImageUrl: productImageUrl,
      price: price,
      originalPrice: originalPrice,
      quantity: _toInt(map['quantity'], defaultValue: 1),
      color: CartColor(
        name: (colorData['name'] ?? '').toString(),
        code: colorData['code']?.toString(),
      ),
      stock: stock,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  static double _toDouble(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
  
  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Convert sang Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_brand': productBrand,
      'product_image_url': productImageUrl,
      'price': price,
      'original_price': originalPrice,
      'quantity': quantity,
      'color_name': color.name,
      'color_code': color.code,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Tạo bản sao với quantity mới
  CartModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productBrand,
    String? productImageUrl,
    double? price,
    double? originalPrice,
    int? quantity,
    CartColor? color,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBrand: productBrand ?? this.productBrand,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      color: color ?? this.color,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Tính tổng tiền cho item này
  double get totalPrice => price * quantity;
}

/// Color model for cart item
class CartColor {
  final String name;
  final String? code;

  CartColor({required this.name, this.code});

  Map<String, dynamic> toMap() => {'name': name, 'code': code};
}

class CartSummary {
  final List<CartModel> items;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;

  CartSummary({
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
  });

  /// Tạo CartSummary từ danh sách items
  factory CartSummary.fromItems(List<CartModel> items) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    // Free shipping if subtotal >= 500,000 VND
    final shippingFee = subtotal >= 500000 ? 0.0 : 30000.0;
    const taxRate = 0.1; // 10% tax
    final tax = subtotal * taxRate;
    final total = subtotal + shippingFee + tax;

    return CartSummary(
      items: items,
      subtotal: subtotal,
      shippingFee: shippingFee,
      tax: tax,
      total: total,
    );
  }

  /// Số lượng items trong giỏ hàng
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);
}
