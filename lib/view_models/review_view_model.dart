import 'package:flutter/material.dart';

class ReviewViewModel {
  final String avatarUrl;
  final String name;
  final String time;
  final String sentiment;
  final Color sentimentColor;
  final String reviewText;
  final double aiScore;
  final double rating;
  final String tag;

  ReviewViewModel({
    required this.avatarUrl,
    required this.name,
    required this.time,
    required this.sentiment,
    required this.sentimentColor,
    required this.reviewText,
    required this.aiScore,
    required this.rating,
    required this.tag,
  });
}
