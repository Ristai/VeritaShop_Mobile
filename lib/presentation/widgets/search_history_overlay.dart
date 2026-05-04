import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SearchHistoryOverlay extends StatelessWidget {
  final List<String> searchHistory;
  final List<String> suggestions;
  final String currentQuery;
  final void Function(String) onItemTap;
  final void Function(String) onRemove;
  final VoidCallback onClearAll;
  final VoidCallback onClose;

  const SearchHistoryOverlay({
    super.key,
    required this.searchHistory,
    required this.suggestions,
    required this.currentQuery,
    required this.onItemTap,
    required this.onRemove,
    required this.onClearAll,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final items = currentQuery.isEmpty ? searchHistory : suggestions;

    if (items.isEmpty && currentQuery.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentQuery.isEmpty) _buildHeader(context),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(context, items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 18, color: colors.secondaryText),
              const SizedBox(width: 8),
              Text(
                'Tìm kiếm gần đây',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onClearAll,
            child: const Text(
              'Xóa tất cả',
              style: TextStyle(
                color: kRedColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String item) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: () => onItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              currentQuery.isEmpty ? Icons.history : Icons.search,
              size: 18,
              color: colors.secondaryText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: currentQuery.isEmpty
                  ? Text(item, style: TextStyle(color: colors.primaryText))
                  : _buildHighlightedText(context, item),
            ),
            if (currentQuery.isEmpty)
              GestureDetector(
                onTap: () => onRemove(item),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: colors.secondaryText,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context, String text) {
    final colors = AppColors.of(context);
    final lowerText = text.toLowerCase();
    final lowerQuery = currentQuery.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: TextStyle(color: colors.primaryText));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: colors.primaryText),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + currentQuery.length),
            style: const TextStyle(
              color: kAccentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + currentQuery.length)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: colors.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có lịch sử tìm kiếm',
            style: TextStyle(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class PopularSearches extends StatelessWidget {
  final List<String> searches;
  final void Function(String) onTap;

  const PopularSearches({
    super.key,
    required this.searches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.trending_up, size: 18, color: kAccentColor),
              const SizedBox(width: 8),
              Text(
                'Tìm kiếm phổ biến',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searches.map((search) {
            return GestureDetector(
              onTap: () => onTap(search),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  search,
                  style: TextStyle(fontSize: 13, color: colors.primaryText),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
