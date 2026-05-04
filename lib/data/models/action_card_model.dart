/// Model dữ liệu thẻ hành động
class ActionCardModel {
  final String id;
  final String title;
  final String description;
  final String status; // 'Khẩn cấp', 'Lên lịch', 'Sẵn sàng'
  final DateTime? dueDate;
  final String? priority; // 'High', 'Medium', 'Low'

  ActionCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    this.priority,
  });

  /// Tạo copy với các giá trị mới
  ActionCardModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    String? priority,
  }) {
    return ActionCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }
}

