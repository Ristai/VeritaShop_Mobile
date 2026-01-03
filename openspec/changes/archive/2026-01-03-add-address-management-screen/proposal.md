# Proposal: Add Address Management Screen

## Why
Hiện tại, khi user click vào "Địa chỉ giao hàng" trong Profile, chỉ hiện thông báo "Vui lòng thêm địa chỉ khi thanh toán". User phải nhập lại địa chỉ mỗi lần checkout, gây bất tiện.

## What Changes
Tạo màn hình quản lý địa chỉ giao hàng cho phép:
- Xem danh sách địa chỉ đã lưu
- Thêm địa chỉ mới
- Chỉnh sửa địa chỉ
- Xóa địa chỉ
- Đặt địa chỉ mặc định

Địa chỉ đã lưu sẽ được tự động load trong checkout để user chọn thay vì phải nhập mới.

## Scope

### Tạo mới
- `lib/presentation/screens/address_list_screen.dart` - Màn hình danh sách địa chỉ

### Cập nhật
- `lib/presentation/screens/profile_screen.dart` - Navigate đến address screen thay vì hiện snackbar
- `lib/core/routes/app_routes.dart` - Thêm route `/addresses`

### Tái sử dụng
- `AddressModel` - Đã có sẵn
- `OrderViewModel` - Đã có các methods `loadAddresses()`, `addAddress()`, `updateAddress()`, `deleteAddress()`
- Form thêm địa chỉ trong checkout - Có thể extract thành widget dùng chung

## Impact
- **User Experience**: Tiết kiệm thời gian khi checkout, không phải nhập lại địa chỉ
- **Low Risk**: Tận dụng code đã có trong OrderViewModel
- **Files affected**: ~3 files
