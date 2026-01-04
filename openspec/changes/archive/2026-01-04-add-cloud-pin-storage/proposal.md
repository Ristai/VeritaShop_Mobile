# Change: Lưu trữ mã PIN trên Cloud (MongoDB)

## Why
Hiện tại PIN được lưu trữ local trên device (FlutterSecureStorage). Điều này gây ra vấn đề:
- User không thể đồng bộ PIN giữa các thiết bị
- Admin không thể quản lý/reset PIN cho user
- Khi user đổi device, phải setup PIN lại từ đầu

Bằng cách lưu PIN hash trên MongoDB, user có thể:
- Sử dụng cùng một PIN trên nhiều thiết bị
- Chỉnh sửa PIN từ Settings
- Admin có thể reset PIN khi cần

## What Changes

### Backend (Node.js)
- Thêm fields `pinHash`, `pinEnabled` vào User schema
- Tạo API endpoints mới:
  - `POST /api/users/pin` - Tạo/cập nhật PIN
  - `POST /api/users/pin/verify` - Xác thực PIN
  - `PUT /api/users/pin/toggle` - Bật/tắt PIN
  - `DELETE /api/users/pin` - Xóa PIN

### Mobile App (Flutter)
- Thêm API methods trong `ApiService`
- Cập nhật `PinService` để gọi API thay vì local storage
- Cập nhật `PinViewModel` để sync với cloud
- Cập nhật Settings screen với UI chỉnh sửa PIN

## Impact
- Affected specs: `settings-screen`
- Affected backend: `User.js`, `userRoutes.js`, `userController.js`
- Affected mobile: `api_service.dart`, `pin_service.dart`, `pin_view_model.dart`, `settings_screen.dart`

## Security Considerations
- PIN hash được tạo ở client-side bằng SHA-256 trước khi gửi lên server
- Server lưu trữ PIN hash, KHÔNG lưu plaintext
- Xác thực PIN vẫn có lockout mechanism (5 lần sai = khóa 5 phút)
- Lockout state lưu ở client để tránh timing attacks
