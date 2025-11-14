/// Model dữ liệu thẻ insight
class InsightCardModel {
  final String id;
  final String title;
  final String description;
  final String tag; // 'Insight', 'Recommendation', 'Action Required', 'Prediction'
  final String info; // Thông tin bổ sung (ví dụ: 'Độ tin cậy: 94%')
  final double? confidence; // Độ tin cậy (0-1)

  InsightCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.info,
    this.confidence,
  });

  /// Tạo copy với các giá trị mới
  InsightCardModel copyWith({
    String? id,
    String? title,
    String? description,
    String? tag,
    String? info,
    double? confidence,
  }) {
    return InsightCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      info: info ?? this.info,
      confidence: confidence ?? this.confidence,
    );
  }
}

