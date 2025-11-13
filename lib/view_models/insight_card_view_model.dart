import 'package:flutter/material.dart';

/// Lớp này là một mô hình dữ liệu (data model) để lưu trữ thông tin
/// cần thiết cho việc hiển thị một thẻ "AI Insight & Đề xuất".
/// Nó không chứa bất kỳ code giao diện nào.
class InsightCardViewModel {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final String info;

  const InsightCardViewModel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.info,
  });
}
