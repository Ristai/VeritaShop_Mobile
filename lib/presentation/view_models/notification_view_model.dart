import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';

/// ViewModel quản lý thông báo cho người dùng
class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _selectedFilter = 'all'; // 'all', 'order', 'promo'

  List<NotificationModel> get notifications {
    if (_selectedFilter == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  List<NotificationModel> get allNotifications => _notifications;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationViewModel() {
    loadNotifications();
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
