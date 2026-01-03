/// Sentiment analysis item for a single aspect
class SentimentAnalysisItem {
  final String aspect;
  final String sentiment;
  final double confidence;
  final Map<String, double> scores;

  SentimentAnalysisItem({
    required this.aspect,
    required this.sentiment,
    this.confidence = 0.0,
    this.scores = const {},
  });

  factory SentimentAnalysisItem.fromMap(Map<String, dynamic> map) {
    // Handle scores - could be nested object or null
    Map<String, double> parsedScores = {};
    if (map['scores'] != null && map['scores'] is Map) {
      final scores = map['scores'] as Map;
      parsedScores = {
        'positive': (scores['positive'] ?? 0).toDouble(),
        'negative': (scores['negative'] ?? 0).toDouble(),
        'neutral': (scores['neutral'] ?? 0).toDouble(),
      };
    }

    return SentimentAnalysisItem(
      aspect: map['aspect']?.toString() ?? 'General',
      sentiment: map['sentiment']?.toString() ?? 'neutral',
      confidence: (map['confidence'] ?? 0).toDouble(),
      scores: parsedScores,
    );
  }

  /// Get Vietnamese name for aspect
  String get aspectVietnamese {
    const aspectMap = {
      'Battery': 'Pin',
      'Camera': 'Camera',
      'Performance': 'Hiệu năng',
      'Display': 'Màn hình',
      'Design': 'Thiết kế',
      'Packaging': 'Đóng gói',
      'Price': 'Giá',
      'Shop_Service': 'Dịch vụ',
      'Shipping': 'Giao hàng',
      'General': 'Chung',
    };
    return aspectMap[aspect] ?? aspect;
  }

  /// Get Vietnamese name for sentiment
  String get sentimentVietnamese {
    switch (sentiment) {
      case 'positive':
        return 'Tích cực';
      case 'negative':
        return 'Tiêu cực';
      default:
        return 'Trung tính';
    }
  }
}

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
  final String overallSentiment;
  final String tag;
  final List<String> images;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;
  final List<SentimentAnalysisItem> sentimentAnalysis;

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
    this.overallSentiment = 'neutral',
    this.tag = 'Sản phẩm',
    this.images = const [],
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
    this.sentimentAnalysis = const [],
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

  /// Get Vietnamese overall sentiment
  String get overallSentimentVietnamese {
    switch (overallSentiment) {
      case 'positive':
        return 'Tích cực';
      case 'negative':
        return 'Tiêu cực';
      case 'mixed':
        return 'Hỗn hợp';
      default:
        return 'Trung tính';
    }
  }

  /// Create from API response
  factory ReviewModel.fromApiMap(Map<String, dynamic> map) {
    final user = map['user'] ?? {};

    // Handle product - can be String ID or Object
    String productId = '';
    final product = map['product'];
    if (product is String) {
      productId = product;
    } else if (product is Map) {
      productId = product['_id']?.toString() ?? product['id']?.toString() ?? '';
    } else {
      productId = map['productId']?.toString() ?? '';
    }

    // Parse sentiment analysis array
    List<SentimentAnalysisItem> sentimentList = [];
    if (map['sentimentAnalysis'] != null && map['sentimentAnalysis'] is List) {
      sentimentList = (map['sentimentAnalysis'] as List)
          .map((item) => SentimentAnalysisItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    // Determine sentiment from API or fallback to rating-based
    String displaySentiment;
    final apiSentiment = map['overallSentiment'] as String?;
    if (apiSentiment != null && apiSentiment.isNotEmpty) {
      displaySentiment = _getSentimentVietnameseFromApi(apiSentiment);
    } else {
      displaySentiment = _getSentimentFromRating((map['rating'] ?? 3).toDouble());
    }

    // Calculate AI score from sentiment analysis if available
    double calculatedAiScore = 0.0;
    if (sentimentList.isNotEmpty) {
      calculatedAiScore = sentimentList
          .map((s) => s.confidence)
          .reduce((a, b) => a + b) / sentimentList.length;
    }

    return ReviewModel(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      userId: user['_id']?.toString() ?? user['id']?.toString() ?? map['userId']?.toString() ?? '',
      userName: user['name']?.toString() ?? 'Người dùng',
      avatarUrl: user['avatar']?.toString() ?? '',
      productId: productId,
      title: map['title']?.toString(),
      reviewText: map['text']?.toString() ?? map['reviewText']?.toString() ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      aiScore: calculatedAiScore,
      sentiment: displaySentiment,
      overallSentiment: map['overallSentiment'] ?? 'neutral',
      tag: sentimentList.isNotEmpty ? sentimentList.first.aspectVietnamese : 'Sản phẩm',
      images: List<String>.from(map['images'] ?? []),
      likes: map['likes'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      sentimentAnalysis: sentimentList,
    );
  }

  static String _getSentimentFromRating(double rating) {
    if (rating >= 4) return 'Tích cực';
    if (rating >= 3) return 'Trung tính';
    return 'Tiêu cực';
  }

  static String _getSentimentVietnameseFromApi(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return 'Tích cực';
      case 'negative':
        return 'Tiêu cực';
      case 'mixed':
        return 'Hỗn hợp';
      default:
        return 'Trung tính';
    }
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
    String? overallSentiment,
    String? tag,
    List<String>? images,
    int? likes,
    bool? isLiked,
    DateTime? createdAt,
    List<SentimentAnalysisItem>? sentimentAnalysis,
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
      overallSentiment: overallSentiment ?? this.overallSentiment,
      tag: tag ?? this.tag,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      sentimentAnalysis: sentimentAnalysis ?? this.sentimentAnalysis,
    );
  }
}
