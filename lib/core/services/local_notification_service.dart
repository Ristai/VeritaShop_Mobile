import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

/// Service quản lý Local Notifications
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Notification channels
  static const String orderChannelId = 'order_channel';
  static const String promoChannelId = 'promo_channel';
  static const String reminderChannelId = 'reminder_channel';

  // Callback khi user tap vào notification
  Function(String? payload)? onNotificationTap;

  /// Khởi tạo notification service
  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Tạo notification channels cho Android
    await _createNotificationChannels();
  }

  /// Xử lý khi user tap vào notification
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    onNotificationTap?.call(response.payload);
  }

  /// Tạo notification channels (Android 8.0+)
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Order channel - High priority
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          orderChannelId,
          'Đơn hàng',
          description: 'Thông báo về trạng thái đơn hàng',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Promo channel - Default priority
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          promoChannelId,
          'Khuyến mãi',
          description: 'Thông báo về khuyến mãi và ưu đãi',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );

      // Reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          reminderChannelId,
          'Nhắc nhở',
          description: 'Thông báo nhắc nhở',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  /// Yêu cầu quyền notification
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  /// Kiểm tra quyền notification
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true;
  }

  /// Hiển thị notification ngay lập tức
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    final details = _getNotificationDetails(type);

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Lên lịch notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    final details = _getNotificationDetails(type);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Lên lịch notification lặp lại hàng ngày
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
    NotificationType type = NotificationType.reminder,
  }) async {
    final details = _getNotificationDetails(type);
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // Nếu thời gian đã qua hôm nay, schedule cho ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time, // Lặp lại hàng ngày
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Hủy notification theo id
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Hủy tất cả notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Lấy danh sách pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Lấy notification details theo type
  NotificationDetails _getNotificationDetails(NotificationType type) {
    String channelId;
    String channelName;
    Importance importance;
    Priority priority;

    switch (type) {
      case NotificationType.order:
        channelId = orderChannelId;
        channelName = 'Đơn hàng';
        importance = Importance.high;
        priority = Priority.high;
        break;
      case NotificationType.promo:
        channelId = promoChannelId;
        channelName = 'Khuyến mãi';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case NotificationType.reminder:
        channelId = reminderChannelId;
        channelName = 'Nhắc nhở';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      default:
        channelId = 'default_channel';
        channelName = 'Thông báo';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: priority,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ==================== CONVENIENCE METHODS ====================

  /// Hiển thị notification ngay lập tức (generic)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Auto-detect notification type from payload
    NotificationType type = NotificationType.general;
    if (payload?.startsWith('order:') == true) {
      type = NotificationType.order;
    } else if (payload?.startsWith('promo:') == true) {
      type = NotificationType.promo;
    }

    await showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      type: type,
    );
  }

  /// Thông báo đơn hàng mới
  Future<void> notifyNewOrder(String orderId) async {
    await showNotification(
      id: orderId.hashCode,
      title: 'Đặt hàng thành công',
      body: 'Đơn hàng #$orderId đã được xác nhận. Cảm ơn bạn đã mua sắm!',
      payload: 'order:$orderId',
      type: NotificationType.order,
    );
  }

  /// Thông báo cập nhật trạng thái đơn hàng
  Future<void> notifyOrderStatusChange({
    required String orderId,
    required String status,
  }) async {
    String title;
    String body;

    switch (status.toLowerCase()) {
      case 'processing':
        title = 'Đơn hàng đang xử lý';
        body = 'Đơn hàng #$orderId đang được chuẩn bị';
        break;
      case 'shipped':
        title = 'Đơn hàng đang giao';
        body = 'Đơn hàng #$orderId đã được giao cho đơn vị vận chuyển';
        break;
      case 'delivered':
        title = 'Giao hàng thành công';
        body = 'Đơn hàng #$orderId đã được giao. Hãy đánh giá sản phẩm nhé!';
        break;
      case 'cancelled':
        title = 'Đơn hàng đã hủy';
        body = 'Đơn hàng #$orderId đã bị hủy';
        break;
      default:
        title = 'Cập nhật đơn hàng';
        body = 'Đơn hàng #$orderId: $status';
    }

    await showNotification(
      id: '$orderId-$status'.hashCode,
      title: title,
      body: body,
      payload: 'order:$orderId',
      type: NotificationType.order,
    );
  }

  /// Thông báo khuyến mãi
  Future<void> notifyPromo({
    required String title,
    required String description,
    String? promoCode,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: description,
      payload: promoCode != null ? 'promo:$promoCode' : null,
      type: NotificationType.promo,
    );
  }

  /// Nhắc nhở giỏ hàng bị bỏ quên
  Future<void> scheduleCartReminder({
    required int itemCount,
    Duration delay = const Duration(hours: 2),
  }) async {
    final scheduledTime = DateTime.now().add(delay);

    await scheduleNotification(
      id: 'cart_reminder'.hashCode,
      title: 'Giỏ hàng đang chờ bạn',
      body: 'Bạn có $itemCount sản phẩm trong giỏ hàng. Hoàn tất đơn hàng ngay!',
      scheduledTime: scheduledTime,
      payload: 'cart',
      type: NotificationType.reminder,
    );
  }

  /// Nhắc nhở đánh giá sản phẩm
  Future<void> scheduleReviewReminder({
    required String productName,
    required String orderId,
    Duration delay = const Duration(days: 3),
  }) async {
    final scheduledTime = DateTime.now().add(delay);

    await scheduleNotification(
      id: 'review_$orderId'.hashCode,
      title: 'Đánh giá sản phẩm',
      body: 'Bạn thấy $productName thế nào? Hãy chia sẻ đánh giá của bạn!',
      scheduledTime: scheduledTime,
      payload: 'review:$orderId',
      type: NotificationType.reminder,
    );
  }
}

/// Loại notification
enum NotificationType {
  general,
  order,
  promo,
  reminder,
}
