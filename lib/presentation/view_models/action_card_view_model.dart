import 'package:flutter/material.dart';
import '../../data/models/action_card_model.dart';
import '../../core/constants/app_colors.dart';

/// ViewModel cho ActionCard - kết hợp data model với UI properties
class ActionCardViewModel {
  final ActionCardModel? model;
  
  // UI-specific properties
  final IconData icon;
  final Color iconColor;
  final String title;
  final String status;
  final Color statusColor;
  final String description;

  ActionCardViewModel({
    this.model,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.description,
  });

  /// Factory constructor từ ActionCardModel
  factory ActionCardViewModel.fromModel(ActionCardModel model) {
    // Map status to icon and colors
    IconData icon;
    Color iconColor;
    Color statusColor;

    switch (model.status) {
      case 'Khẩn cấp':
        icon = Icons.error_outline;
        iconColor = kRedColor;
        statusColor = kRedColor;
        break;
      case 'Lên lịch':
        icon = Icons.update;
        iconColor = kYellowColor;
        statusColor = kYellowColor;
        break;
      case 'Sẵn sàng':
      default:
        icon = Icons.description_outlined;
        iconColor = kAccentColor;
        statusColor = kGreenColor;
        break;
    }

    return ActionCardViewModel(
      model: model,
      icon: icon,
      iconColor: iconColor,
      title: model.title,
      status: model.status,
      statusColor: statusColor,
      description: model.description,
    );
  }
}

