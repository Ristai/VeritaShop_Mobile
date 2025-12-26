class CouponModel {
  final String id;
  final String code;
  final String description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double? maxDiscountAmount;
  final double minOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int? usageLimit;
  final int usedCount;
  final int usagePerUser;

  CouponModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minOrderAmount = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.usageLimit,
    this.usedCount = 0,
    this.usagePerUser = 1,
  });

  factory CouponModel.fromMap(Map<String, dynamic> map) {
    return CouponModel(
      id: map['_id'] ?? map['id'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      discountType: map['discountType'] ?? 'percentage',
      discountValue: (map['discountValue'] ?? 0).toDouble(),
      maxDiscountAmount: map['maxDiscountAmount']?.toDouble(),
      minOrderAmount: (map['minOrderAmount'] ?? 0).toDouble(),
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate']) 
          : DateTime.now(),
      endDate: map['endDate'] != null 
          ? DateTime.parse(map['endDate']) 
          : DateTime.now().add(const Duration(days: 30)),
      isActive: map['isActive'] ?? true,
      usageLimit: map['usageLimit'],
      usedCount: map['usedCount'] ?? 0,
      usagePerUser: map['usagePerUser'] ?? 1,
    );
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isNotStarted => DateTime.now().isBefore(startDate);
  bool get isValid => isActive && !isExpired && !isNotStarted && !isUsageLimitReached;
  
  bool get isUsageLimitReached => usageLimit != null && usedCount >= usageLimit!;
  
  int? get remainingUsage => usageLimit != null ? usageLimit! - usedCount : null;

  String get usageLimitText {
    if (usageLimit == null) {
      return 'Không giới hạn lượt dùng';
    }
    final remaining = usageLimit! - usedCount;
    if (remaining <= 0) {
      return 'Đã hết lượt sử dụng';
    }
    return 'Còn $remaining/${usageLimit!} lượt';
  }

  String get usagePerUserText {
    if (usagePerUser <= 1) {
      return 'Mỗi người dùng 1 lần';
    }
    return 'Mỗi người tối đa $usagePerUser lần';
  }

  String get discountText {
    if (discountType == 'percentage') {
      String text = 'Giảm ${discountValue.toInt()}%';
      if (maxDiscountAmount != null) {
        text += ' tối đa ${_formatPrice(maxDiscountAmount!)}';
      }
      return text;
    } else {
      return 'Giảm ${_formatPrice(discountValue)}';
    }
  }

  String get minOrderText {
    if (minOrderAmount > 0) {
      return 'Đơn tối thiểu ${_formatPrice(minOrderAmount)}';
    }
    return 'Không giới hạn';
  }

  String get expiryText {
    final remaining = endDate.difference(DateTime.now());
    if (remaining.inDays > 0) {
      return 'Còn ${remaining.inDays} ngày';
    } else if (remaining.inHours > 0) {
      return 'Còn ${remaining.inHours} giờ';
    } else {
      return 'Sắp hết hạn';
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}tr';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return '${price.toStringAsFixed(0)}đ';
  }

  double calculateDiscount(double orderAmount) {
    if (orderAmount < minOrderAmount) return 0;
    
    double discount;
    if (discountType == 'percentage') {
      discount = orderAmount * discountValue / 100;
      if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
        discount = maxDiscountAmount!;
      }
    } else {
      discount = discountValue;
    }
    
    return discount > orderAmount ? orderAmount : discount;
  }
}

class AppliedCoupon {
  final CouponModel coupon;
  final double discountAmount;
  final double finalAmount;

  AppliedCoupon({
    required this.coupon,
    required this.discountAmount,
    required this.finalAmount,
  });

  factory AppliedCoupon.fromMap(Map<String, dynamic> map) {
    return AppliedCoupon(
      coupon: CouponModel.fromMap(map['coupon'] ?? {}),
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      finalAmount: (map['finalAmount'] ?? 0).toDouble(),
    );
  }
}
