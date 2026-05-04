# Change: Add Admin CRUD Management for Users and Carts

## Why
Admin hiện tại chỉ có thể xem danh sách User và toggle trạng thái. Cần mở rộng để admin có thể:
- Tạo, sửa, xóa User và reset mật khẩu
- Quản lý giỏ hàng của tất cả users (xem, sửa, xóa)

Điều này giúp admin có khả năng hỗ trợ khách hàng tốt hơn (sửa thông tin, reset mật khẩu) và xử lý các vấn đề liên quan đến giỏ hàng.

## What Changes

### Backend (Node.js)
- **ADDED**: API endpoints cho Full CRUD User (create, update, delete)
- **ADDED**: API endpoint reset password cho User
- **ADDED**: API endpoints cho Admin Cart Management (list all carts, view cart by user, update cart item, delete cart item)

### Mobile App (Flutter)
- **MODIFIED**: `admin_users_screen.dart` - Thêm UI cho Create/Edit/Delete User + Reset Password
- **ADDED**: `AdminUserViewModel` - Thêm methods cho full CRUD + reset password
- **ADDED**: `admin_carts_screen.dart` - Màn hình quản lý giỏ hàng
- **ADDED**: `AdminCartViewModel` - ViewModel cho quản lý giỏ hàng
- **MODIFIED**: `AdminRepository` - Thêm methods cho User CRUD và Cart management
- **MODIFIED**: `ApiService` - Thêm API calls cho các endpoints mới

## Impact
- Affected specs: `admin-management` (new capability)
- Affected code:
  - Backend: `adminController.js`, `adminRoutes.js`
  - Flutter: `admin_users_screen.dart`, `admin_repository.dart`, `api_service.dart`
  - New files: `admin_carts_screen.dart`, `admin_cart_view_model.dart`
- No breaking changes to existing functionality
- Requires database access to User and Cart collections
