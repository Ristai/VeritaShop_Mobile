import 'package:flutter/material.dart';
import '../../data/models/review_model.dart';
import '../../core/constants/app_colors.dart';

/// ViewModel cho Review - kết hợp data model với UI properties
class ReviewViewModel {
  final ReviewModel review;

  ReviewViewModel({required this.review});

  // Delegate to review model
  String get id => review.id;
  String get userId => review.userId;
  String get name => review.userName;
  String get avatarUrl => review.avatarUrl;
  String get productId => review.productId;
  String get reviewText => review.reviewText;
  double get rating => review.rating;
  double get aiScore => review.aiScore;
  String get sentiment => review.sentiment;
  String get tag => review.tag;
  DateTime get createdAt => review.createdAt;
  String get time => review.timeAgo;

  /// Màu sắc cho sentiment (UI-specific)
  Color get sentimentColor {
    switch (sentiment) {
      case 'Tích cực':
        return kGreenColor;
      case 'Tiêu cực':
        return kRedColor;
      case 'Trung tính':
      default:
        return kYellowColor;
    }
  }

  /// Factory constructor từ ReviewModel
  factory ReviewViewModel.fromModel(ReviewModel model) {
    return ReviewViewModel(review: model);
  }

  /// Named constructor với tất cả parameters (để tương thích với code hiện tại)
  ReviewViewModel.fromParams({
    required String avatarUrl,
    required String name,
    required String time,
    required String sentiment,
    required Color sentimentColor,
    required String reviewText,
    required double aiScore,
    required double rating,
    required String tag,
  }) : review = ReviewModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '',
          userName: name,
          avatarUrl: avatarUrl,
          productId: '',
          reviewText: reviewText,
          rating: rating,
          aiScore: aiScore,
          sentiment: sentiment,
          tag: tag,
          createdAt: DateTime.now(),
        );
}

