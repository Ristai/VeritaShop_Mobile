import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../../core/network/api_service.dart';

/// Repository quản lý notifications
class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Lấy danh sách notifications của user
  Future<NotificationListResult> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      debugPrint('NotificationRepository: Fetching notifications...');
      final response = await _apiService.getNotifications(
        page: page,
        limit: limit,
        type: type,
      );
      debugPrint('NotificationRepository: Response = $response');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        debugPrint('NotificationRepository: Data = $data');
        final List<dynamic> notificationsData = data['notifications'] ?? [];
        final pagination = response['pagination'] ?? {};

        debugPrint('NotificationRepository: Found ${notificationsData.length} notifications');

        final notifications = notificationsData
            .map((json) => NotificationModel.fromApiJson(json))
            .toList();

        return NotificationListResult(
          notifications: notifications,
          unreadCount: data['unreadCount'] ?? 0,
          page: pagination['page'] ?? 1,
          totalPages: pagination['totalPages'] ?? 1,
          total: pagination['total'] ?? notifications.length,
        );
      }

      debugPrint('NotificationRepository: No data or success=false');
      return NotificationListResult(
        notifications: [],
        unreadCount: 0,
        page: 1,
        totalPages: 1,
        total: 0,
      );
    } catch (e) {
      debugPrint('NotificationRepository: Error fetching notifications: $e');
      return NotificationListResult(
        notifications: [],
        unreadCount: 0,
        page: 1,
        totalPages: 1,
        total: 0,
      );
    }
  }

  /// Đánh dấu notification đã đọc
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.markNotificationAsRead(notificationId);
      return response['success'] == true;
    } catch (e) {
      debugPrint('NotificationRepository: Error marking as read: $e');
      return false;
    }
  }

  /// Đánh dấu tất cả notifications đã đọc
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();
      return response['success'] == true;
    } catch (e) {
      debugPrint('NotificationRepository: Error marking all as read: $e');
      return false;
    }
  }

  /// Xóa notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.deleteNotification(notificationId);
      return response['success'] == true;
    } catch (e) {
      debugPrint('NotificationRepository: Error deleting notification: $e');
      return false;
    }
  }
}

/// Kết quả trả về khi lấy danh sách notifications
class NotificationListResult {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int page;
  final int totalPages;
  final int total;

  NotificationListResult({
    required this.notifications,
    required this.unreadCount,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}
