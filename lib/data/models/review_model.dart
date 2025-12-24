/// Model dữ liệu đánh giá sản phẩm
class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String avatarUrl;
  final String productId;
  final String? title;
  final String reviewText;
  final double rating;
  final double aiScore;
  final String sentiment;
  final String tag;
  final List<String> images;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.productId,
    this.title,
    required this.reviewText,
    required this.rating,
    this.aiScore = 0.0,
    this.sentiment = 'Trung tính',
    this.tag = 'Sản phẩm',
    this.images = const [],
    this.likes = 0,
    this.isLiked = false,
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

  /// Create from API response
  factory ReviewModel.fromApiMap(Map<String, dynamic> map) {
    final user = map['user'] ?? {};
    final product = map['product'] ?? {};
    
    return ReviewModel(
      id: map['_id'] ?? map['id'] ?? '',
      userId: user['_id'] ?? user['id'] ?? map['userId'] ?? '',
      userName: user['name'] ?? 'Người dùng',
      avatarUrl: user['avatar'] ?? '',
      productId: product['_id'] ?? product['id'] ?? map['productId'] ?? '',
      title: map['title'],
      reviewText: map['text'] ?? map['reviewText'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      aiScore: (map['aiScore'] ?? 0).toDouble(),
      sentiment: _getSentimentFromRating((map['rating'] ?? 3).toDouble()),
      tag: 'Sản phẩm',
      images: List<String>.from(map['images'] ?? []),
      likes: map['likes'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  static String _getSentimentFromRating(double rating) {
    if (rating >= 4) return 'Tích cực';
    if (rating >= 3) return 'Trung tính';
    return 'Tiêu cực';
  }

  /// Tạo copy với các giá trị mới
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? avatarUrl,
    String? productId,
    String? title,
    String? reviewText,
    double? rating,
    double? aiScore,
    String? sentiment,
    String? tag,
    List<String>? images,
    int? likes,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      reviewText: reviewText ?? this.reviewText,
      rating: rating ?? this.rating,
      aiScore: aiScore ?? this.aiScore,
      sentiment: sentiment ?? this.sentiment,
      tag: tag ?? this.tag,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

