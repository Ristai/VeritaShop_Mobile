/// Model dữ liệu chủ đề đang thịnh hành
class TrendingTopicModel {
  final String id;
  final String topic;
  final int mentions;
  final double positivePercentage; // Phần trăm tích cực (0-100)
  final double neutralPercentage;
  final double negativePercentage;
  final String status; // 'Hot', 'Trending', 'Cần chú ý', 'Ổn định'

  TrendingTopicModel({
    required this.id,
    required this.topic,
    required this.mentions,
    required this.positivePercentage,
    required this.neutralPercentage,
    required this.negativePercentage,
    required this.status,
  });

  /// Format số lượng mentions
  String get formattedMentions {
    if (mentions >= 1000) {
      return '${(mentions / 1000).toStringAsFixed(1)}K mentions';
    }
    return '$mentions mentions';
  }

  /// Format sentiment (ví dụ: "Tích cực 89%")
  String get formattedSentiment {
    if (positivePercentage >= 70) {
      return 'Tích cực ${positivePercentage.toInt()}%';
    } else if (negativePercentage >= 50) {
      return 'Tiêu cực ${negativePercentage.toInt()}%';
    } else {
      return 'Trung tính ${neutralPercentage.toInt()}%';
    }
  }

  /// Tạo copy với các giá trị mới
  TrendingTopicModel copyWith({
    String? id,
    String? topic,
    int? mentions,
    double? positivePercentage,
    double? neutralPercentage,
    double? negativePercentage,
    String? status,
  }) {
    return TrendingTopicModel(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      mentions: mentions ?? this.mentions,
      positivePercentage: positivePercentage ?? this.positivePercentage,
      neutralPercentage: neutralPercentage ?? this.neutralPercentage,
      negativePercentage: negativePercentage ?? this.negativePercentage,
      status: status ?? this.status,
    );
  }
}

