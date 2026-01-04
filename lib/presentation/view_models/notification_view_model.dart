import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../core/services/local_notification_service.dart';

/// ViewModel quản lý thông báo cho người dùng
class NotificationViewModel extends ChangeNotifier {
  final LocalNotificationService _notificationService = LocalNotificationService();
  final NotificationRepository _notificationRepository;

  List<NotificationModel> _notifications = [];
  Set<String> _knownNotificationIds = {}; // Track IDs đã biết
  bool _isLoading = false;
  String _selectedFilter = 'all'; // 'all', 'order', 'promo'
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String? _errorMessage;
  int _serverUnreadCount = 0;

  NotificationViewModel({NotificationRepository? notificationRepository})
      : _notificationRepository = notificationRepository ?? NotificationRepository() {
    // Only initialize notification service, don't load data yet
    // Data will be loaded when user is authenticated or when screen is opened
    _initNotificationService();
  }

  List<NotificationModel> get notifications {
    if (_selectedFilter == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  List<NotificationModel> get allNotifications => _notifications;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _serverUnreadCount > 0
      ? _serverUnreadCount
      : _notifications.where((n) => !n.isRead).length;

  /// Khởi tạo notification service và load notifications
  Future<void> initialize() async {
    await _initNotificationService();
    await loadNotifications();
  }

  /// Khởi tạo notification service
  Future<void> _initNotificationService() async {
    await _notificationService.initialize();

    // Xử lý khi user tap vào notification
    _notificationService.onNotificationTap = _handleNotificationTap;
  }

  /// Xử lý khi user tap vào notification
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    debugPrint('Notification payload: $payload');

    // Parse payload và xử lý navigation
    if (payload.startsWith('order:')) {
      final orderId = payload.replaceFirst('order:', '');
      debugPrint('Navigate to order: $orderId');
      // TODO: Navigate to order detail
    } else if (payload.startsWith('promo:')) {
      final promoCode = payload.replaceFirst('promo:', '');
      debugPrint('Apply promo code: $promoCode');
      // TODO: Navigate to promo or apply code
    } else if (payload == 'cart') {
      debugPrint('Navigate to cart');
      // TODO: Navigate to cart
    } else if (payload.startsWith('review:')) {
      final orderId = payload.replaceFirst('review:', '');
      debugPrint('Navigate to review for order: $orderId');
      // TODO: Navigate to review screen
    }
  }

  /// Yêu cầu quyền notification
  Future<bool> requestNotificationPermission() async {
    return await _notificationService.requestPermission();
  }

  /// Kiểm tra quyền notification
  Future<bool> hasNotificationPermission() async {
    return await _notificationService.hasPermission();
  }

  /// Bật/tắt thông báo
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    if (!enabled) {
      _notificationService.cancelAllNotifications();
    }
    notifyListeners();
  }

  /// Bật/tắt âm thanh thông báo
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  /// Tải danh sách thông báo từ API
  Future<void> loadNotifications({bool showPushForNew = true}) async {
    debugPrint('NotificationViewModel: loadNotifications called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _notificationRepository.getNotifications();
      debugPrint('NotificationViewModel: Got ${result.notifications.length} notifications, unread: ${result.unreadCount}');

      // Detect new notifications and show push notification
      if (showPushForNew && _notificationsEnabled && _knownNotificationIds.isNotEmpty) {
        for (final notification in result.notifications) {
          if (!_knownNotificationIds.contains(notification.id) && !notification.isRead) {
            // This is a new notification - show push notification
            debugPrint('NotificationViewModel: New notification detected: ${notification.title}');
            await _showPushNotificationForNew(notification);
          }
        }
      }

      // Update known IDs
      _knownNotificationIds = result.notifications.map((n) => n.id).toSet();

      _notifications = result.notifications;
      _serverUnreadCount = result.unreadCount;
      _errorMessage = null;
    } catch (e) {
      debugPrint('NotificationViewModel: Error loading notifications: $e');
      _errorMessage = 'Không thể tải thông báo';
      // Giữ nguyên notifications hiện tại nếu có lỗi
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Hiển thị push notification cho notification mới
  Future<void> _showPushNotificationForNew(NotificationModel notification) async {
    if (notification.isOrderNotification) {
      // Extract orderId from data if available
      final orderId = notification.data?['orderId'] ?? notification.data?['orderNumber'] ?? '';
      await _notificationService.showInstantNotification(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.message,
        payload: 'order:$orderId',
      );
    } else if (notification.isPromoNotification) {
      final promoCode = notification.data?['couponCode'] ?? '';
      await _notificationService.showInstantNotification(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.message,
        payload: promoCode.isNotEmpty ? 'promo:$promoCode' : 'promo',
      );
    } else {
      await _notificationService.showInstantNotification(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.message,
        payload: 'notification:${notification.id}',
      );
    }
  }

  /// Thêm notification mới vào danh sách (local)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _serverUnreadCount++;
    notifyListeners();
  }

  /// Đặt filter theo loại thông báo
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Đánh dấu một thông báo đã đọc
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      // Update local state first
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      if (_serverUnreadCount > 0) _serverUnreadCount--;
      notifyListeners();

      // Sync với server
      await _notificationRepository.markAsRead(notificationId);
    }
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    // Update local state first
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _serverUnreadCount = 0;
    notifyListeners();

    // Sync với server
    await _notificationRepository.markAllAsRead();
  }

  /// Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );

    // Update local state first
    _notifications.removeWhere((n) => n.id == notificationId);
    if (!notification.isRead && _serverUnreadCount > 0) _serverUnreadCount--;
    notifyListeners();

    // Sync với server
    await _notificationRepository.deleteNotification(notificationId);
  }

  // ==================== LOCAL NOTIFICATION METHODS ====================

  /// Gửi thông báo đơn hàng mới (local push notification)
  Future<void> sendOrderNotification(String orderId) async {
    if (!_notificationsEnabled) return;

    await _notificationService.notifyNewOrder(orderId);

    // Refresh từ server để lấy notification mới
    await loadNotifications();
  }

  /// Gửi thông báo cập nhật trạng thái đơn hàng
  Future<void> sendOrderStatusNotification({
    required String orderId,
    required String status,
  }) async {
    if (!_notificationsEnabled) return;

    await _notificationService.notifyOrderStatusChange(
      orderId: orderId,
      status: status,
    );

    // Refresh từ server để lấy notification mới
    await loadNotifications();
  }

  /// Gửi thông báo khuyến mãi
  Future<void> sendPromoNotification({
    required String title,
    required String description,
    String? promoCode,
  }) async {
    if (!_notificationsEnabled) return;

    await _notificationService.notifyPromo(
      title: title,
      description: description,
      promoCode: promoCode,
    );

    // Refresh từ server để lấy notification mới
    await loadNotifications();
  }

  /// Đặt lịch nhắc nhở giỏ hàng
  Future<void> scheduleCartReminder(int itemCount) async {
    if (!_notificationsEnabled) return;
    await _notificationService.scheduleCartReminder(itemCount: itemCount);
  }

  /// Đặt lịch nhắc nhở đánh giá
  Future<void> scheduleReviewReminder({
    required String productName,
    required String orderId,
  }) async {
    if (!_notificationsEnabled) return;
    await _notificationService.scheduleReviewReminder(
      productName: productName,
      orderId: orderId,
    );
  }

  /// Hủy tất cả thông báo đã lên lịch
  Future<void> cancelAllScheduledNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
