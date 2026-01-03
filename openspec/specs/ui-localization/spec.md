# ui-localization Specification

## Purpose
TBD - created by archiving change vietnamese-ui-localization. Update Purpose after archive.
## Requirements
### Requirement: Vietnamese Cart Screen Text
Màn hình giỏ hàng MUST hiển thị tất cả text bằng tiếng Việt để đồng bộ với màn hình thanh toán.

#### Scenario: Cart screen displays Vietnamese labels
- **Given** người dùng mở màn hình giỏ hàng
- **When** giỏ hàng có sản phẩm
- **Then** AppBar hiển thị "Giỏ hàng của tôi"
- **And** các label hiển thị: "Tạm tính", "Phí vận chuyển", "Thuế", "Tổng cộng"
- **And** button hiển thị "Tiến hành thanh toán"

#### Scenario: Cart empty state shows Vietnamese text
- **Given** người dùng mở màn hình giỏ hàng
- **When** giỏ hàng trống
- **Then** hiển thị message "Giỏ hàng trống"
- **And** hiển thị sub-message "Thêm sản phẩm để bắt đầu"
- **And** button hiển thị "Tiếp tục mua sắm"

#### Scenario: Cart dialogs show Vietnamese text
- **Given** người dùng muốn xóa sản phẩm khỏi giỏ hàng
- **When** dialog xác nhận xuất hiện
- **Then** title hiển thị "Xóa sản phẩm"
- **And** buttons hiển thị "Hủy" và "Xóa"

