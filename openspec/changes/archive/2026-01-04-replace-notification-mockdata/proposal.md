# Change: Replace notification mock data with real persistent notifications

## Why
Hiện tại màn hình Thông báo (Notifications) hiển thị mock data hardcoded. Khi người dùng thanh toán thành công (COD/MoMo), đơn hàng được tạo, hay có các sự kiện khác, notification được tạo nhưng chỉ lưu trong memory và sẽ mất khi app restart. Cần lưu trữ notifications thực sự để người dùng có thể xem lịch sử thông báo.

## What Changes
- **Backend**: Thêm Notification model trong MongoDB để lưu trữ thông báo của user
- **Backend**: Thêm API endpoints để CRUD notifications (GET list, POST create, PATCH mark read, DELETE)
- **Frontend**: Thay thế mock data bằng API calls để fetch notifications từ server
- **Frontend**: Tự động tạo notification khi đặt hàng thành công (gọi API)
- **Frontend**: Lưu notifications vào local storage để offline access (optional enhancement)

## Impact
- Affected specs: notifications (new capability)
- Affected code:
  - `backend/src/models/` - Thêm Notification.js
  - `backend/src/controllers/` - Thêm notificationController.js
  - `backend/src/routes/` - Thêm notificationRoutes.js
  - `lib/data/repositories/` - Thêm notification_repository.dart
  - `lib/presentation/view_models/notification_view_model.dart` - Replace mock data
  - `lib/core/network/api_service.dart` - Thêm notification API methods

## Analysis: Có cần lưu trong MongoDB không?

### Lý do NÊN lưu trong MongoDB:
1. **Persistence**: User có thể xem lại thông báo sau khi restart app
2. **Cross-device**: Nếu user đăng nhập trên thiết bị khác, vẫn thấy thông báo cũ
3. **Admin use cases**: Admin có thể gửi thông báo promotional cho nhiều users
4. **Order tracking**: Lưu lại lịch sử trạng thái đơn hàng dưới dạng notifications
5. **Analytics**: Có thể phân tích tỷ lệ đọc thông báo

### Recommendation:
**CÓ** - Nên lưu notifications trong MongoDB vì:
- App ecommerce cần notification history cho order status
- User mong đợi có thể xem lại thông báo đã nhận
- Backend có thể push thông báo khi order status thay đổi từ admin
