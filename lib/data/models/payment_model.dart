/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled,
  refunded,
}

/// Payment method enum
enum PaymentMethod {
  cod,
  momo,
  vnpay,
  zalopay,
  card,
}

/// Payment Model representing a payment transaction
class PaymentModel {
  final String id;
  final String orderId;
  final String userId;
  final PaymentMethod method;
  final double amount;
  final String requestId;
  final String? momoOrderId;
  final String? transId;
  final String? payUrl;
  final String? deeplink;
  final String? qrCodeUrl;
  final PaymentStatus status;
  final int? resultCode;
  final String? message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.method,
    required this.amount,
    required this.requestId,
    this.momoOrderId,
    this.transId,
    this.payUrl,
    this.deeplink,
    this.qrCodeUrl,
    this.status = PaymentStatus.pending,
    this.resultCode,
    this.message,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get localized status text
  String get statusText {
    switch (status) {
      case PaymentStatus.pending:
        return 'Chờ thanh toán';
      case PaymentStatus.processing:
        return 'Đang xử lý';
      case PaymentStatus.success:
        return 'Thành công';
      case PaymentStatus.failed:
        return 'Thất bại';
      case PaymentStatus.cancelled:
        return 'Đã hủy';
      case PaymentStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }

  /// Parse payment status from string
  static PaymentStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  /// Parse payment method from string
  static PaymentMethod _parseMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'cod':
        return PaymentMethod.cod;
      case 'momo':
        return PaymentMethod.momo;
      case 'vnpay':
        return PaymentMethod.vnpay;
      case 'zalopay':
        return PaymentMethod.zalopay;
      case 'card':
        return PaymentMethod.card;
      default:
        return PaymentMethod.cod;
    }
  }

  /// Create PaymentModel from API response
  factory PaymentModel.fromApiMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      orderId: (map['order'] is Map
              ? (map['order']['_id'] ?? map['order']['id'])
              : map['order'] ?? map['orderId'] ?? '')
          .toString(),
      userId: (map['user'] is Map
              ? (map['user']['_id'] ?? map['user']['id'])
              : map['user'] ?? map['userId'] ?? '')
          .toString(),
      method: _parseMethod(map['method']?.toString()),
      amount: _toDouble(map['amount']),
      requestId: (map['requestId'] ?? '').toString(),
      momoOrderId: map['momoOrderId']?.toString(),
      transId: map['transId']?.toString(),
      payUrl: map['payUrl']?.toString(),
      deeplink: map['deeplink']?.toString(),
      qrCodeUrl: map['qrCodeUrl']?.toString(),
      status: _parseStatus(map['status']?.toString()),
      resultCode: map['resultCode'] is int ? map['resultCode'] : null,
      message: map['message']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  /// Safe type conversion for double
  static double _toDouble(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Create a copy with updated fields
  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    PaymentMethod? method,
    double? amount,
    String? requestId,
    String? momoOrderId,
    String? transId,
    String? payUrl,
    String? deeplink,
    String? qrCodeUrl,
    PaymentStatus? status,
    int? resultCode,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      requestId: requestId ?? this.requestId,
      momoOrderId: momoOrderId ?? this.momoOrderId,
      transId: transId ?? this.transId,
      payUrl: payUrl ?? this.payUrl,
      deeplink: deeplink ?? this.deeplink,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      status: status ?? this.status,
      resultCode: resultCode ?? this.resultCode,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// MoMo Payment Response from API
class MomoPaymentResponse {
  final String paymentId;
  final String requestId;
  final String momoOrderId;
  final String? payUrl;
  final String? deeplink;
  final String? qrCodeUrl;
  final double amount;
  final PaymentStatus status;

  MomoPaymentResponse({
    required this.paymentId,
    required this.requestId,
    required this.momoOrderId,
    this.payUrl,
    this.deeplink,
    this.qrCodeUrl,
    required this.amount,
    this.status = PaymentStatus.pending,
  });

  factory MomoPaymentResponse.fromApiMap(Map<String, dynamic> map) {
    final payment = map['payment'] as Map<String, dynamic>? ?? map;
    return MomoPaymentResponse(
      paymentId: (payment['id'] ?? payment['_id'] ?? '').toString(),
      requestId: (payment['requestId'] ?? '').toString(),
      momoOrderId: (payment['momoOrderId'] ?? '').toString(),
      payUrl: payment['payUrl']?.toString(),
      deeplink: payment['deeplink']?.toString(),
      qrCodeUrl: payment['qrCodeUrl']?.toString(),
      amount: _toDouble(payment['amount']),
      status: _parseStatus(payment['status']?.toString()),
    );
  }

  static double _toDouble(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static PaymentStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

/// Payment Status Response from checking status
class PaymentStatusResponse {
  final PaymentModel payment;
  final String orderId;
  final String orderNumber;
  final String orderStatus;
  final String paymentStatus;

  PaymentStatusResponse({
    required this.payment,
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentStatus,
  });

  factory PaymentStatusResponse.fromApiMap(Map<String, dynamic> map) {
    final paymentData = map['payment'] as Map<String, dynamic>? ?? {};
    final orderData = map['order'] as Map<String, dynamic>? ?? {};

    return PaymentStatusResponse(
      payment: PaymentModel.fromApiMap(paymentData),
      orderId: (orderData['id'] ?? orderData['_id'] ?? '').toString(),
      orderNumber: (orderData['orderNumber'] ?? '').toString(),
      orderStatus: (orderData['status'] ?? 'pending').toString(),
      paymentStatus: (orderData['paymentStatus'] ?? 'pending').toString(),
    );
  }

  bool get isPaymentSuccess => payment.status == PaymentStatus.success;
  bool get isPaymentFailed => payment.status == PaymentStatus.failed;
  bool get isPaymentCancelled => payment.status == PaymentStatus.cancelled;
  bool get isPaymentPending => payment.status == PaymentStatus.pending || payment.status == PaymentStatus.processing;
}
