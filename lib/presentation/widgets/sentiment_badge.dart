import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/review_model.dart';

/// Widget hiển thị badge sentiment cho từng aspect
class SentimentBadge extends StatelessWidget {
  final SentimentAnalysisItem item;
  final bool compact;

  const SentimentBadge({
    super.key,
    required this.item,
    this.compact = false,
  });

  Color get _sentimentColor {
    switch (item.sentiment) {
      case 'positive':
        return kGreenColor;
      case 'negative':
        return kRedColor;
      default:
        return kYellowColor;
    }
  }

  IconData get _sentimentIcon {
    switch (item.sentiment) {
      case 'positive':
        return Icons.sentiment_satisfied_alt;
      case 'negative':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactBadge();
    }
    return _buildFullBadge();
  }

  Widget _buildCompactBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _sentimentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _sentimentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_sentimentIcon, size: 12, color: _sentimentColor),
          const SizedBox(width: 4),
          Text(
            item.aspectVietnamese,
            style: TextStyle(
              color: _sentimentColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _sentimentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _sentimentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_sentimentIcon, size: 14, color: _sentimentColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.aspectVietnamese,
                style: TextStyle(
                  color: _sentimentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.sentimentVietnamese,
                style: TextStyle(
                  color: _sentimentColor.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị danh sách sentiment badges
class SentimentBadgeList extends StatelessWidget {
  final List<SentimentAnalysisItem> sentimentAnalysis;
  final bool compact;
  final int maxItems;

  const SentimentBadgeList({
    super.key,
    required this.sentimentAnalysis,
    this.compact = true,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (sentimentAnalysis.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayItems = sentimentAnalysis.take(maxItems).toList();
    final remainingCount = sentimentAnalysis.length - maxItems;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...displayItems.map((item) => SentimentBadge(
              item: item,
              compact: compact,
            )),
        if (remainingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget hiển thị overall sentiment badge
class OverallSentimentBadge extends StatelessWidget {
  final String overallSentiment;
  final String? label;

  const OverallSentimentBadge({
    super.key,
    required this.overallSentiment,
    this.label,
  });

  Color get _color {
    switch (overallSentiment) {
      case 'positive':
        return kGreenColor;
      case 'negative':
        return kRedColor;
      case 'mixed':
        return kPurpleColor;
      default:
        return kYellowColor;
    }
  }

  IconData get _icon {
    switch (overallSentiment) {
      case 'positive':
        return Icons.sentiment_satisfied_alt;
      case 'negative':
        return Icons.sentiment_dissatisfied;
      case 'mixed':
        return Icons.swap_horiz;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String get _text {
    switch (overallSentiment) {
      case 'positive':
        return 'Tích cực';
      case 'negative':
        return 'Tiêu cực';
      case 'mixed':
        return 'Hỗn hợp';
      default:
        return 'Trung tính';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            label ?? _text,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
