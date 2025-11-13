import 'package:flutter/material.dart';

class TrendingTopicViewModel {
  final String topic;
  final String mentions;
  final String sentiment;
  final Color sentimentColor;
  final IconData statusIcon;
  final String statusText;
  final Color statusColor;

  TrendingTopicViewModel({
    required this.topic,
    required this.mentions,
    required this.sentiment,
    required this.sentimentColor,
    required this.statusIcon,
    required this.statusText,
    required this.statusColor,
  });
}
