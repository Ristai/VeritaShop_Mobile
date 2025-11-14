import 'package:flutter/material.dart';
import '../../data/models/insight_card_model.dart';
import '../../core/constants/app_colors.dart';

/// ViewModel cho InsightCard - kết hợp data model với UI properties
class InsightCardViewModel {
  final InsightCardModel? model;
  
  // UI-specific properties
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final String info;

  InsightCardViewModel({
    this.model,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.info,
  });

  /// Factory constructor từ InsightCardModel
  factory InsightCardViewModel.fromModel(InsightCardModel model) {
    // Map tag to icon and color
    IconData icon;
    Color iconColor;
    Color tagColor;

    switch (model.tag) {
      case 'Insight':
        icon = Icons.show_chart;
        iconColor = kAccentColor;
        tagColor = kAccentColor;
        break;
      case 'Recommendation':
        icon = Icons.thumb_up_alt;
        iconColor = kGreenColor;
        tagColor = kGreenColor;
        break;
      case 'Action Required':
        icon = Icons.warning_amber_rounded;
        iconColor = kYellowColor;
        tagColor = kYellowColor;
        break;
      case 'Prediction':
        icon = Icons.online_prediction;
        iconColor = kPurpleColor;
        tagColor = kPurpleColor;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = kAccentColor;
        tagColor = kAccentColor;
        break;
    }

    return InsightCardViewModel(
      model: model,
      icon: icon,
      iconColor: iconColor,
      title: model.title,
      description: model.description,
      tag: model.tag,
      tagColor: tagColor,
      info: model.info,
    );
  }
}

