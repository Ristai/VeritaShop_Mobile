# Tasks: Simplify Bottom Navigation

## Implementation Tasks

### Phase 1: Create Notification System
- [x] **1.1** Tạo `NotificationModel` trong `lib/data/models/notification_model.dart`
- [x] **1.2** Tạo `NotificationViewModel` trong `lib/presentation/view_models/notification_view_model.dart`
- [x] **1.3** Tạo `NotificationsScreen` trong `lib/presentation/screens/notifications_screen.dart`

### Phase 2: Update Bottom Navigation
- [x] **2.1** Cập nhật `HomeScreen` với 5 tab (Trang chủ, Giỏ hàng, Thông báo, Hồ sơ, Cài đặt)
- [x] **2.2** Thêm badge cho Giỏ hàng và Thông báo icons
- [x] **2.3** Cập nhật `ProductListScreen` với embedded mode
- [x] **2.4** Cập nhật `CartScreen` với embedded mode
- [x] **2.5** Cập nhật `ProfileScreen` với embedded mode

### Phase 3: Update Navigation Flow
- [x] **3.1** Cập nhật `login_screen.dart` → navigate đến `HomeScreen`
- [x] **3.2** Cập nhật `register_screen.dart` → navigate đến `HomeScreen`
- [x] **3.3** Đăng ký `NotificationViewModel` trong `main.dart`

### Phase 4: Cleanup
- [x] **4.1** Xóa import không sử dụng
- [x] **4.2** Chạy `flutter analyze` - không có lỗi

## Completion Status
✅ **All tasks completed**

## Files Changed
- `lib/data/models/notification_model.dart` (new)
- `lib/presentation/view_models/notification_view_model.dart` (new)
- `lib/presentation/screens/notifications_screen.dart` (new)
- `lib/presentation/screens/home_screen.dart` (modified)
- `lib/presentation/screens/product_list_screen.dart` (modified)
- `lib/presentation/screens/cart_screen.dart` (modified)
- `lib/presentation/screens/profile_screen.dart` (modified)
- `lib/presentation/screens/login_screen.dart` (modified)
- `lib/presentation/screens/register_screen.dart` (modified)
- `lib/main.dart` (modified)
