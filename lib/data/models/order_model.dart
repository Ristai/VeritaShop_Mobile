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
