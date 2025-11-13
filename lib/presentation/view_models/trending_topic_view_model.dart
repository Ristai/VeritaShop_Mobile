import 'package:flutter/material.dart';
import '../../data/models/trending_topic_model.dart';
import '../../core/constants/app_colors.dart';

/// ViewModel cho TrendingTopic - kết hợp data model với UI properties
class TrendingTopicViewModel {
  final TrendingTopicModel? model;
  
  // UI-specific properties
  final String topic;
  final String mentions;
  final String sentiment;
  final Color sentimentColor;
  final IconData statusIcon;
  final String statusText;
  final Color statusColor;

  TrendingTopicViewModel({
    this.model,
    required this.topic,
    required this.mentions,
    required this.sentiment,
    required this.sentimentColor,
    required this.statusIcon,
    required this.statusText,
    required this.statusColor,
  });

  /// Factory constructor từ TrendingTopicModel
  factory TrendingTopicViewModel.fromModel(TrendingTopicModel model) {
    // Map sentiment to color
    Color sentimentColor;
    if (model.positivePercentage >= 70) {
      sentimentColor = kGreenColor;
    } else if (model.negativePercentage >= 50) {
      sentimentColor = kRedColor;
    } else {
      sentimentColor = kYellowColor;
    }

    // Map status to icon and color
    IconData statusIcon;
    Color statusColor;
    switch (model.status) {
      case 'Hot':
        statusIcon = Icons.arrow_upward;
        statusColor = kRedColor;
        break;
      case 'Trending':
        statusIcon = Icons.trending_up;
        statusColor = kAccentColor;
        break;
      case 'Cần chú ý':
        statusIcon = Icons.arrow_downward;
        statusColor = kYellowColor;
        break;
      case 'Ổn định':
      default:
        statusIcon = Icons.horizontal_rule;
        statusColor = kSecondaryTextColor;
        break;
    }

    return TrendingTopicViewModel(
      model: model,
      topic: model.topic,
      mentions: model.formattedMentions,
      sentiment: model.formattedSentiment,
      sentimentColor: sentimentColor,
      statusIcon: statusIcon,
      statusText: model.status,
      statusColor: statusColor,
    );
  }
}

