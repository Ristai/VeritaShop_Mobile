class CartModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create CartModel từ Map
  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      productImageUrl: map['product_image_url'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert sang Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_image_url': productImageUrl,
      'price': price,
      'quantity': quantity,
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
    String? productImageUrl,
    double? price,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Tính tổng tiền cho item này
  double get totalPrice => price * quantity;
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
    const shippingFee = 30000.0; // 30k shipping fee
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
