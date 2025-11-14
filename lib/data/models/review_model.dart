/// Model dữ liệu đánh giá sản phẩm
class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String avatarUrl;
  final String productId;
  final String reviewText;
  final double rating;
  final double aiScore; // Điểm phân tích sentiment từ AI (0.0 - 1.0)
  final String sentiment; // 'Tích cực', 'Trung tính', 'Tiêu cực'
  final String tag; // Tag phân loại: 'Dịch vụ', 'Sản phẩm', 'Hỗ trợ', etc.
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.productId,
    required this.reviewText,
    required this.rating,
    required this.aiScore,
    required this.sentiment,
    required this.tag,
    required this.createdAt,
  });

  /// Format thời gian đăng (ví dụ: "2 phút trước")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Tạo copy với các giá trị mới
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? avatarUrl,
    String? productId,
    String? reviewText,
    double? rating,
    double? aiScore,
    String? sentiment,
    String? tag,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      productId: productId ?? this.productId,
      reviewText: reviewText ?? this.reviewText,
      rating: rating ?? this.rating,
      aiScore: aiScore ?? this.aiScore,
      sentiment: sentiment ?? this.sentiment,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

