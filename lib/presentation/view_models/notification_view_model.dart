import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../core/services/local_notification_service.dart';

/// ViewModel quản lý thông báo cho người dùng
class NotificationViewModel extends ChangeNotifier {
  final LocalNotificationService _notificationService = LocalNotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _selectedFilter = 'all'; // 'all', 'order', 'promo'
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

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

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationViewModel() {
    _initNotificationService();
    loadNotifications();
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

  /// Tải danh sách thông báo (mock data)
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    // Giả lập delay network
    await Future.delayed(const Duration(milliseconds: 500));

    _notifications = _getMockNotifications();
    _isLoading = false;
    notifyListeners();
  }

  /// Thêm notification mới vào danh sách
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Đặt filter theo loại thông báo
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Đánh dấu một thông báo đã đọc
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Đánh dấu tất cả thông báo đã đọc
  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  /// Xóa thông báo
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // ==================== LOCAL NOTIFICATION METHODS ====================

  /// Gửi thông báo đơn hàng mới
  Future<void> sendOrderNotification(String orderId) async {
    if (!_notificationsEnabled) return;

    await _notificationService.notifyNewOrder(orderId);

    // Thêm vào danh sách thông báo trong app
    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'order',
      title: '🎉 Đặt hàng thành công!',
      message: 'Đơn hàng #$orderId đã được xác nhận.',
      timestamp: DateTime.now(),
      isRead: false,
      data: {'orderId': orderId},
    ));
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

    // Thêm vào danh sách
    String title;
    String message;

    switch (status.toLowerCase()) {
      case 'processing':
        title = '📦 Đơn hàng đang xử lý';
        message = 'Đơn hàng #$orderId đang được chuẩn bị';
        break;
      case 'shipped':
        title = '🚚 Đơn hàng đang giao';
        message = 'Đơn hàng #$orderId đã được giao cho đơn vị vận chuyển';
        break;
      case 'delivered':
        title = '✅ Giao hàng thành công';
        message = 'Đơn hàng #$orderId đã được giao';
        break;
      default:
        title = '📋 Cập nhật đơn hàng';
        message = 'Đơn hàng #$orderId: $status';
    }

    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'order',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      data: {'orderId': orderId},
    ));
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

    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'promo',
      title: '🔥 $title',
      message: description,
      timestamp: DateTime.now(),
      isRead: false,
      data: promoCode != null ? {'couponCode': promoCode} : null,
    ));
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

  /// Mock data cho thông báo
  List<NotificationModel> _getMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        type: 'order',
        title: 'Đơn hàng đã được xác nhận',
        message: 'Đơn hàng #VT2024001 của bạn đã được xác nhận và đang được chuẩn bị.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        data: {'orderId': 'VT2024001'},
      ),
      NotificationModel(
        id: '2',
        type: 'promo',
        title: 'Flash Sale - Giảm 30%!',
        message: 'iPhone 15 Pro Max đang giảm giá 30% chỉ trong hôm nay. Nhanh tay đặt hàng!',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        data: {'productId': 'iphone-15-pro-max'},
      ),
      NotificationModel(
        id: '3',
        type: 'order',
        title: 'Đơn hàng đang được giao',
        message: 'Đơn hàng #VT2024000 đang trên đường giao đến bạn. Dự kiến nhận hàng trong 2 giờ.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        data: {'orderId': 'VT2024000'},
      ),
      NotificationModel(
        id: '4',
        type: 'promo',
        title: 'Mã giảm giá mới dành cho bạn',
        message: 'Nhập mã VERITA50K để được giảm 50.000đ cho đơn hàng từ 500.000đ.',
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
        data: {'couponCode': 'VERITA50K'},
      ),
      NotificationModel(
        id: '5',
        type: 'order',
        title: 'Đơn hàng đã hoàn thành',
        message: 'Đơn hàng #VT2023999 đã được giao thành công. Cảm ơn bạn đã mua sắm!',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        data: {'orderId': 'VT2023999'},
      ),
      NotificationModel(
        id: '6',
        type: 'promo',
        title: 'Sản phẩm mới - Samsung Galaxy S24',
        message: 'Samsung Galaxy S24 Ultra vừa ra mắt! Đặt trước ngay để nhận quà tặng hấp dẫn.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        data: {'productId': 'samsung-s24-ultra'},
      ),
      NotificationModel(
        id: '7',
        type: 'promo',
        title: 'Ưu đãi cuối tuần',
        message: 'Giảm thêm 10% cho tất cả phụ kiện điện thoại trong cuối tuần này.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }
}
