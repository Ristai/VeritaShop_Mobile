import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../view_models/notification_view_model.dart';

/// Màn hình hiển thị danh sách thông báo
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Consumer<NotificationViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Filter tabs
            _buildFilterTabs(context, viewModel, colors),
            // Notification list
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.notifications.isEmpty
                      ? _buildEmptyState(colors)
                      : _buildNotificationList(context, viewModel, colors),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterTabs(
    BuildContext context,
    NotificationViewModel viewModel,
    AppColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tất cả',
            isSelected: viewModel.selectedFilter == 'all',
            onTap: () => viewModel.setFilter('all'),
            colors: colors,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Đơn hàng',
            isSelected: viewModel.selectedFilter == 'order',
            onTap: () => viewModel.setFilter('order'),
            colors: colors,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Khuyến mãi',
            isSelected: viewModel.selectedFilter == 'promo',
            onTap: () => viewModel.setFilter('promo'),
            colors: colors,
          ),
          const Spacer(),
          if (viewModel.unreadCount > 0)
            TextButton(
              onPressed: viewModel.markAllAsRead,
              child: const Text('Đọc tất cả'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: colors.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có thông báo nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thông báo về đơn hàng và khuyến mãi sẽ xuất hiện ở đây',
            style: TextStyle(
              fontSize: 14,
              color: colors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    NotificationViewModel viewModel,
    AppColors colors,
  ) {
    return RefreshIndicator(
      onRefresh: viewModel.loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = viewModel.notifications[index];
          return _NotificationCard(
            notification: notification,
            colors: colors,
            onTap: () {
              viewModel.markAsRead(notification.id);
              _handleNotificationTap(context, notification);
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Navigate đến trang đơn hàng nếu là thông báo đơn hàng
    if (notification.isOrderNotification) {
      Navigator.pushNamed(context, '/orders');
      return;
    }
    
    // Các loại thông báo khác (khuyến mãi, hệ thống)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kAccentColor : colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kAccentColor : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colors.primaryText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final AppColors colors;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIcon(),
                color: _getIconBackgroundColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: kAccentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.timestamp),
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (notification.isOrderNotification) {
      final title = notification.title.toLowerCase();
      if (title.contains('xác nhận')) return Icons.check_circle_outline;
      if (title.contains('giao')) return Icons.local_shipping_outlined;
      if (title.contains('hoàn thành')) return Icons.done_all;
      if (title.contains('hủy')) return Icons.cancel_outlined;
      return Icons.inventory_2_outlined;
    } else {
      final title = notification.title.toLowerCase();
      if (title.contains('giảm') || title.contains('sale')) return Icons.local_offer_outlined;
      if (title.contains('mã')) return Icons.confirmation_number_outlined;
      if (title.contains('mới')) return Icons.new_releases_outlined;
      return Icons.card_giftcard_outlined;
    }
  }

  Color _getIconBackgroundColor() {
    if (notification.isOrderNotification) {
      return kAccentColor;
    } else {
      return kGreenColor;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
