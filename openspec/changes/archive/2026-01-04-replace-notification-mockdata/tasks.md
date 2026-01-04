## 1. Backend Implementation

- [x] 1.1 Create Notification model (`backend/src/models/Notification.js`)
  - Schema với userId, type, title, message, data, isRead, timestamps
  - Index on userId + createdAt
  - TTL index để auto-delete old notifications (30 days)

- [x] 1.2 Create notificationController (`backend/src/controllers/notificationController.js`)
  - `getNotifications` - paginated list với filter by type
  - `markAsRead` - single notification
  - `markAllAsRead` - bulk update
  - `deleteNotification` - single delete
  - `createNotification` - internal helper function

- [x] 1.3 Create notification routes (`backend/src/routes/notificationRoutes.js`)
  - Mount at `/api/notifications`
  - Protected by auth middleware

- [x] 1.4 Integrate with orderController
  - Auto-create notification khi order được tạo
  - Auto-create notification khi order status thay đổi (adminController)

- [x] 1.5 Add notification API to server.js routes

## 2. Frontend Implementation

- [x] 2.1 Add notification API methods to ApiService (`lib/core/network/api_service.dart`)
  - `getNotifications(page, limit, type)`
  - `markNotificationAsRead(id)`
  - `markAllNotificationsAsRead()`
  - `deleteNotification(id)`

- [x] 2.2 Create NotificationRepository (`lib/data/repositories/notification_repository.dart`)
  - Handle API calls
  - Map responses to NotificationModel

- [x] 2.3 Update NotificationViewModel (`lib/presentation/view_models/notification_view_model.dart`)
  - Replace `_getMockNotifications()` với API call
  - Implement pull-to-refresh
  - Handle loading/error states
  - Show push notification for new notifications

- [x] 2.4 Update NotificationModel (`lib/data/models/notification_model.dart`)
  - Ensure fromJson handles API response format
  - Add `fromApiJson` for MongoDB format

- [x] 2.5 Update NotificationsScreen (`lib/presentation/screens/notifications_screen.dart`)
  - Convert to StatefulWidget
  - Load notifications on screen open

## 3. Testing & Verification

- [x] 3.1 Test backend APIs
  - Create notification (via order creation)
  - Get notifications list
  - Mark read
  - Delete

- [x] 3.2 Test frontend flow
  - App startup loads real notifications
  - Đặt hàng COD tạo notification mới
  - Mark as read updates UI
  - Pull-to-refresh works

- [x] 3.3 Test edge cases
  - No notifications (empty state)
  - Error handling
