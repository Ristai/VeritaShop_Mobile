import 'cart_model.dart';
import 'address_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipping,
  shipped,
  delivered,
  completed,
  cancelled,
  refunded,
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final List<CartModel> items;
  final AddressModel shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? note;

  OrderModel({
    required this.id,
    this.orderNumber = '',
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.note,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipping:
      case OrderStatus.shipped:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);

  static OrderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipping':
        return OrderStatus.shipping;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  factory OrderModel.fromApiMap(Map<String, dynamic> map) {
    final shippingAddr = map['shippingAddress'] as Map<String, dynamic>? ?? {};
    final List<dynamic> itemsData = map['items'] ?? [];
    
    // Safe type conversion helpers
    double toDouble(dynamic value, {double defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }
    
    return OrderModel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      orderNumber: (map['orderNumber'] ?? '').toString(),
      userId: (map['user'] is Map ? (map['user']['_id'] ?? map['user']['id']) : map['user'] ?? map['userId'] ?? '').toString(),
      items: itemsData.map((item) => CartModel.fromApiMap(item as Map<String, dynamic>)).toList(),
      shippingAddress: AddressModel(
        id: '',
        userId: '',
        fullName: (shippingAddr['fullName'] ?? '').toString(),
        phone: (shippingAddr['phone'] ?? '').toString(),
        province: (shippingAddr['province'] ?? '').toString(),
        district: (shippingAddr['district'] ?? '').toString(),
        ward: (shippingAddr['ward'] ?? '').toString(),
        streetAddress: (shippingAddr['streetAddress'] ?? '').toString(),
        isDefault: false,
        createdAt: DateTime.now(),
      ),
      paymentMethod: (map['paymentMethod'] ?? 'COD').toString(),
      subtotal: toDouble(map['subtotal']),
      shippingFee: toDouble(map['shippingFee']),
      tax: toDouble(map['tax']),
      total: toDouble(map['total']),
      status: _parseStatus(map['status']?.toString()),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
      note: map['note']?.toString(),
    );
  }

  factory OrderModel.fromCartSummary({
    required String id,
    required String userId,
    required CartSummary cartSummary,
    required AddressModel shippingAddress,
    required String paymentMethod,
    String? note,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      items: cartSummary.items,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      subtotal: cartSummary.subtotal,
      shippingFee: cartSummary.shippingFee,
      tax: cartSummary.tax,
      total: cartSummary.total,
      createdAt: DateTime.now(),
      note: note,
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    List<CartModel>? items,
    AddressModel? shippingAddress,
    String? paymentMethod,
    double? subtotal,
    double? shippingFee,
    double? tax,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }
}
