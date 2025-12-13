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
    final items = currentQuery.isEmpty ? searchHistory : suggestions;

    if (items.isEmpty && currentQuery.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentQuery.isEmpty) _buildHeader(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.history, size: 18, color: kSecondaryTextColor),
              SizedBox(width: 8),
              Text(
                'Tìm kiếm gần đây',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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

  Widget _buildHistoryItem(String item) {
    return InkWell(
      onTap: () => onItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              currentQuery.isEmpty ? Icons.history : Icons.search,
              size: 18,
              color: kSecondaryTextColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: currentQuery.isEmpty
                  ? Text(item)
                  : _buildHighlightedText(item),
            ),
            if (currentQuery.isEmpty)
              GestureDetector(
                onTap: () => onRemove(item),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: kSecondaryTextColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    final lowerText = text.toLowerCase();
    final lowerQuery = currentQuery.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text);
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: kPrimaryTextColor),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: kSecondaryTextColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có lịch sử tìm kiếm',
            style: TextStyle(color: kSecondaryTextColor),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: kAccentColor),
              SizedBox(width: 8),
              Text(
                'Tìm kiếm phổ biến',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorderColor),
                ),
                child: Text(
                  search,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
