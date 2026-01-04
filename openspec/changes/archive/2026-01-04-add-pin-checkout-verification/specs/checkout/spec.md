## ADDED Requirements

### Requirement: PIN Verification on Checkout
Hệ thống MUST yêu cầu xác thực mã PIN trước khi hoàn tất đặt hàng nếu user đã bật tính năng khóa PIN.

Nếu user CHƯA bật PIN (isPinEnabled = false), hệ thống MUST cho phép đặt hàng bình thường mà không yêu cầu xác thực.

#### Scenario: User có PIN enabled nhấn Đặt hàng
- **WHEN** user có PIN enabled nhấn nút "Đặt hàng"
- **THEN** hệ thống hiển thị bottom sheet yêu cầu nhập mã PIN
- **AND** user MUST nhập đúng mã PIN để tiếp tục

#### Scenario: User nhập đúng PIN
- **WHEN** user nhập đúng mã PIN trong dialog xác thực
- **THEN** hệ thống đóng dialog
- **AND** tiếp tục xử lý đặt hàng như bình thường

#### Scenario: User nhập sai PIN
- **WHEN** user nhập sai mã PIN trong dialog xác thực
- **THEN** hệ thống hiển thị thông báo lỗi "Mã PIN không đúng"
- **AND** cho phép user nhập lại

#### Scenario: User hủy xác thực PIN
- **WHEN** user nhấn nút hủy hoặc đóng dialog xác thực PIN
- **THEN** hệ thống hủy bỏ quá trình đặt hàng
- **AND** quay lại trang checkout

#### Scenario: User không có PIN enabled
- **WHEN** user CHƯA bật tính năng khóa PIN (isPinEnabled = false)
- **AND** user nhấn nút "Đặt hàng"
- **THEN** hệ thống xử lý đặt hàng ngay lập tức
- **AND** KHÔNG hiển thị dialog xác thực PIN
