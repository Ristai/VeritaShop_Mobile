/// Sentiment analysis item for a single aspect
class SentimentAnalysisItem {
  final String aspect;
  final String sentiment;
  final double confidence;
  final Map<String, double> scores;
  final bool aspectOnly; // True if aspect has no sentiment (like "Others")

  SentimentAnalysisItem({
    required this.aspect,
    required this.sentiment,
    this.confidence = 0.0,
    this.scores = const {},
    this.aspectOnly = false,
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

    final sentiment = map['sentiment']?.toString() ?? 'neutral';
    final isAspectOnly = map['aspectOnly'] == true || sentiment == 'none';

    return SentimentAnalysisItem(
      aspect: map['aspect']?.toString() ?? 'General',
      sentiment: sentiment,
      confidence: (map['confidence'] ?? 0).toDouble(),
      scores: parsedScores,
      aspectOnly: isAspectOnly,
    );
  }

  /// Check if this aspect has sentiment analysis
  /// "Others" aspect only has aspect detection, no sentiment
  bool get hasSentiment => !aspectOnly && sentiment != 'none' && aspect != 'Others';

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
      'Others': 'Khác',
    };
    return aspectMap[aspect] ?? aspect;
  }

  /// Get Vietnamese name for sentiment
  String get sentimentVietnamese {
    if (aspectOnly || sentiment == 'none') {
      return 'Không xác định';
    }
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

/// Content moderation result from API
class ModerationResult {
  final String? id;
  final String? model;
  final bool flagged;
  final Map<String, bool> categories;
  final Map<String, double> categoryScores;
  final DateTime? checkedAt;

  ModerationResult({
    this.id,
    this.model,
    this.flagged = false,
    this.categories = const {},
    this.categoryScores = const {},
    this.checkedAt,
  });

  factory ModerationResult.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ModerationResult();
    }

    // Parse categories
    Map<String, bool> parsedCategories = {};
    if (map['categories'] != null && map['categories'] is Map) {
      final categories = map['categories'] as Map;
      categories.forEach((key, value) {
        parsedCategories[key.toString()] = value == true;
      });
    }

    // Parse category scores
    Map<String, double> parsedScores = {};
    if (map['categoryScores'] != null && map['categoryScores'] is Map) {
      final scores = map['categoryScores'] as Map;
      scores.forEach((key, value) {
        parsedScores[key.toString()] = (value ?? 0).toDouble();
      });
    }

    return ModerationResult(
      id: map['id']?.toString(),
      model: map['model']?.toString(),
      flagged: map['flagged'] == true,
      categories: parsedCategories,
      categoryScores: parsedScores,
      checkedAt: map['checkedAt'] != null
          ? DateTime.tryParse(map['checkedAt'].toString())
          : null,
    );
  }

  /// Get flagged category names in Vietnamese
  List<String> get flaggedCategoriesVietnamese {
    const categoryMap = {
      'harassment': 'Quấy rối',
      'harassment/threatening': 'Quấy rối/Đe dọa',
      'hate': 'Thù ghét',
      'hate/threatening': 'Thù ghét/Đe dọa',
      'illicit': 'Bất hợp pháp',
      'illicit/violent': 'Bất hợp pháp/Bạo lực',
      'self-harm': 'Tự gây hại',
      'self-harm/intent': 'Tự gây hại/Ý định',
      'self-harm/instructions': 'Tự gây hại/Hướng dẫn',
      'sexual': 'Nội dung người lớn',
      'sexual/minors': 'Nội dung trẻ em',
      'violence': 'Bạo lực',
      'violence/graphic': 'Bạo lực/Hình ảnh',
    };

    return categories.entries
        .where((entry) => entry.value == true)
        .map((entry) => categoryMap[entry.key] ?? entry.key)
        .toList();
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
  // Moderation fields
  final bool isFlagged;
  final String moderationStatus; // 'pending', 'approved', 'rejected'
  final ModerationResult? moderationResult;
  final String? moderationNote;
  final List<String> flaggedCategoriesVietnamese;

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
    // Moderation defaults
    this.isFlagged = false,
    this.moderationStatus = 'approved',
    this.moderationResult,
    this.moderationNote,
    this.flaggedCategoriesVietnamese = const [],
  });

  /// Check if review is pending moderation
  bool get isPendingModeration => moderationStatus == 'pending';

  /// Check if review was rejected
  bool get isRejected => moderationStatus == 'rejected';

  /// Get moderation status display text in Vietnamese
  String get moderationStatusVietnamese {
    switch (moderationStatus) {
      case 'pending':
        return 'Đang chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Đã từ chối';
      default:
        return 'Không xác định';
    }
  }

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

    // Parse moderation result
    final moderationResult = map['moderationResult'] != null
        ? ModerationResult.fromMap(map['moderationResult'] as Map<String, dynamic>)
        : null;

    // Get flagged categories from API response or from moderation result
    List<String> flaggedCategories = [];
    if (map['flaggedCategoriesVietnamese'] != null && map['flaggedCategoriesVietnamese'] is List) {
      flaggedCategories = List<String>.from(map['flaggedCategoriesVietnamese']);
    } else if (moderationResult != null) {
      flaggedCategories = moderationResult.flaggedCategoriesVietnamese;
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
      // Moderation fields
      isFlagged: map['isFlagged'] == true,
      moderationStatus: map['moderationStatus']?.toString() ?? 'approved',
      moderationResult: moderationResult,
      moderationNote: map['moderationNote']?.toString(),
      flaggedCategoriesVietnamese: flaggedCategories,
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
    bool? isFlagged,
    String? moderationStatus,
    ModerationResult? moderationResult,
    String? moderationNote,
    List<String>? flaggedCategoriesVietnamese,
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
      isFlagged: isFlagged ?? this.isFlagged,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationResult: moderationResult ?? this.moderationResult,
      moderationNote: moderationNote ?? this.moderationNote,
      flaggedCategoriesVietnamese: flaggedCategoriesVietnamese ?? this.flaggedCategoriesVietnamese,
    );
  }
}
