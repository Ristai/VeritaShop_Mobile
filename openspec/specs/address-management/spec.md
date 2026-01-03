# address-management Specification

## Purpose
TBD - created by archiving change add-address-management-screen. Update Purpose after archive.
## Requirements
### Requirement: Address List Screen
Ứng dụng MUST cung cấp màn hình quản lý địa chỉ giao hàng từ Profile để user có thể xem, thêm, sửa, xóa địa chỉ.

#### Scenario: User views address list from profile
- **Given** user đã đăng nhập
- **When** user click "Địa chỉ giao hàng" trong Profile
- **Then** hiển thị màn hình danh sách địa chỉ
- **And** hiển thị tất cả địa chỉ đã lưu với thông tin: tên, SĐT, địa chỉ đầy đủ
- **And** đánh dấu địa chỉ mặc định nếu có

#### Scenario: User adds new address
- **Given** user đang ở màn hình danh sách địa chỉ
- **When** user click nút "Thêm địa chỉ mới"
- **Then** hiển thị form nhập địa chỉ
- **And** form bao gồm: Họ tên, SĐT, Tỉnh/TP, Quận/Huyện, Phường/Xã, Địa chỉ chi tiết
- **And** có checkbox "Đặt làm địa chỉ mặc định"

#### Scenario: User edits existing address
- **Given** user có địa chỉ đã lưu
- **When** user click nút sửa trên một địa chỉ
- **Then** hiển thị form với thông tin địa chỉ hiện tại
- **And** user có thể chỉnh sửa và lưu

#### Scenario: User deletes address
- **Given** user có địa chỉ đã lưu
- **When** user click nút xóa trên một địa chỉ
- **Then** hiển thị dialog xác nhận
- **And** nếu xác nhận thì xóa địa chỉ khỏi danh sách

#### Scenario: Saved addresses appear in checkout
- **Given** user có địa chỉ đã lưu
- **When** user vào màn hình checkout
- **Then** địa chỉ mặc định được tự động chọn
- **And** user có thể chọn địa chỉ khác từ danh sách đã lưu

