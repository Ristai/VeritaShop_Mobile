import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../view_models/admin/admin_review_view_model.dart';
import '../../../data/models/review_model.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminReviewViewModel>().loadReviews();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return formatVietnamDateTime(date);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminReviewViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Quản lý đánh giá',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (vm.flaggedCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag, color: Colors.red.shade700, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${vm.flaggedCount} cần xem xét',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Tất cả'),
                            selected: vm.selectedStatus == null && vm.showFlagged != true,
                            onSelected: (_) => vm.clearFilters(),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Đã duyệt'),
                            selected: vm.selectedStatus == 'approved',
                            onSelected: (_) => vm.setStatusFilter('approved'),
                            backgroundColor: Colors.green.withOpacity(0.1),
                            selectedColor: Colors.green.withOpacity(0.3),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Chờ duyệt'),
                            selected: vm.selectedStatus == 'pending',
                            onSelected: (_) => vm.setStatusFilter('pending'),
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            selectedColor: Colors.orange.withOpacity(0.3),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag, size: 14, color: vm.showFlagged == true ? Colors.white : Colors.red.shade700),
                                const SizedBox(width: 4),
                                Text('Bị đánh dấu', style: TextStyle(
                                  color: vm.showFlagged == true ? Colors.white : Colors.red.shade700,
                                )),
                              ],
                            ),
                            selected: vm.showFlagged == true,
                            onSelected: (_) => vm.setFlaggedFilter(true),
                            backgroundColor: Colors.red.withOpacity(0.1),
                            selectedColor: Colors.red.shade600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.reviews.isEmpty
                        ? const Center(child: Text('Không có đánh giá'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: vm.reviews.length,
                            itemBuilder: (context, index) {
                              final review = vm.reviews[index];
                              return _buildReviewCard(context, vm, review);
                            },
                          ),
              ),
              if (vm.pagination != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: vm.currentPage > 1
                            ? () {
                                if (vm.showFlagged == true) {
                                  vm.loadFlaggedReviews(page: vm.currentPage - 1);
                                } else {
                                  vm.loadReviews(page: vm.currentPage - 1);
                                }
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text('Trang ${vm.currentPage} / ${vm.totalPages}'),
                      IconButton(
                        onPressed: vm.currentPage < vm.totalPages
                            ? () {
                                if (vm.showFlagged == true) {
                                  vm.loadFlaggedReviews(page: vm.currentPage + 1);
                                } else {
                                  vm.loadReviews(page: vm.currentPage + 1);
                                }
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(BuildContext context, AdminReviewViewModel vm, ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _buildProductImage(review.images, 60),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.productId.isNotEmpty ? 'Sản phẩm #${review.productId.substring(0, 8)}' : 'Sản phẩm',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadges(review),
                    ],
                  ),
                ),
              ],
            ),
            // Show flagged categories if review is flagged
            if (review.isFlagged && review.flaggedCategoriesVietnamese.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildModerationCategories(review),
            ],
            const Divider(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: review.avatarUrl.isNotEmpty
                      ? NetworkImage(review.avatarUrl)
                      : null,
                  child: review.avatarUrl.isEmpty
                      ? Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U')
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (review.title != null && review.title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  review.title!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Text(review.reviewText),
            // Show review images if any
            if (review.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          review.images[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildActionButtons(context, vm, review),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadges(ReviewModel review) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        // Moderation status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getModerationStatusColor(review.moderationStatus).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            review.moderationStatusVietnamese,
            style: TextStyle(
              color: _getModerationStatusColor(review.moderationStatus),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Flagged badge
        if (review.isFlagged)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag, size: 12, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Text(
                  'Bị đánh dấu',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModerationCategories(ReviewModel review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, size: 16, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Vi phạm nội dung được phát hiện:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: review.flaggedCategoriesVietnamese.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AdminReviewViewModel vm, ReviewModel review) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Show moderation actions for flagged reviews
        if (review.isFlagged && review.moderationStatus == 'pending') ...[
          ElevatedButton.icon(
            onPressed: () => _confirmApproveModeration(context, vm, review),
            icon: const Icon(Icons.check),
            label: const Text('Duyệt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _confirmRejectModeration(context, vm, review),
            icon: const Icon(Icons.close),
            label: const Text('Từ chối'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ] else ...[
          // Legacy approve for non-flagged pending reviews
          if (review.moderationStatus == 'pending')
            ElevatedButton.icon(
              onPressed: () async {
                final success = await vm.approveReview(review.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã phê duyệt đánh giá')),
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Duyệt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
        ],
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _confirmDelete(context, vm, review),
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text('Xóa', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Color _getModerationStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _confirmApproveModeration(BuildContext context, AdminReviewViewModel vm, ReviewModel review) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyệt đánh giá'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xác nhận duyệt đánh giá này? Nội dung vi phạm sẽ được bỏ qua.'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.approveReviewModeration(
                review.id,
                note: noteController.text.isNotEmpty ? noteController.text : null,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã duyệt đánh giá')),
                );
              }
            },
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );
  }

  void _confirmRejectModeration(BuildContext context, AdminReviewViewModel vm, ReviewModel review) {
    final noteController = TextEditingController(text: 'Nội dung vi phạm quy định cộng đồng');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối đánh giá'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đánh giá này sẽ bị ẩn khỏi hệ thống.'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Lý do từ chối',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.rejectReviewModeration(
                review.id,
                note: noteController.text.isNotEmpty ? noteController.text : null,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã từ chối đánh giá')),
                );
              }
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminReviewViewModel vm, ReviewModel review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa đánh giá này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.deleteReview(review.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa đánh giá')),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(List<String> images, double size) {
    String imageUrl = images.isNotEmpty ? images.first : '';

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image),
    );
  }
}
