import 'cart_model.dart';
import 'address_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipping,
  delivered,
  cancelled,
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
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.cancelled:
        return 'Đã hủy';
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
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  factory OrderModel.fromApiMap(Map<String, dynamic> map) {
    final shippingAddr = map['shippingAddress'] ?? {};
    final List<dynamic> itemsData = map['items'] ?? [];
    
    return OrderModel(
      id: map['_id'] ?? map['id'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      userId: map['user']?['_id'] ?? map['user']?['id'] ?? map['userId'] ?? '',
      items: itemsData.map((item) => CartModel.fromApiMap(item)).toList(),
      shippingAddress: AddressModel(
        id: '',
        userId: '',
        fullName: shippingAddr['fullName'] ?? '',
        phone: shippingAddr['phone'] ?? '',
        province: shippingAddr['province'] ?? '',
        district: shippingAddr['district'] ?? '',
        ward: shippingAddr['ward'] ?? '',
        streetAddress: shippingAddr['streetAddress'] ?? '',
        isDefault: false,
        createdAt: DateTime.now(),
      ),
      paymentMethod: map['paymentMethod'] ?? 'COD',
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: _parseStatus(map['status']),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      note: map['note'],
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
