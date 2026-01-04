## ADDED Requirements

### Requirement: Order Success Notification Timing
Hệ thống MUST chỉ gửi local notification "Đặt hàng thành công" sau khi đơn hàng đã được thanh toán hoàn tất.

- Với phương thức COD: notification được gửi ngay sau khi tạo đơn hàng thành công
- Với phương thức MoMo: notification MUST được gửi SAU khi người dùng hoàn tất thanh toán qua QR code và hệ thống xác nhận thanh toán thành công

#### Scenario: User đặt hàng với COD
- **WHEN** user đặt hàng với phương thức thanh toán COD
- **AND** đơn hàng được tạo thành công
- **THEN** hệ thống gửi local notification "Đặt hàng thành công" ngay lập tức
- **AND** schedule review reminder cho sản phẩm

#### Scenario: User đặt hàng với MoMo - chưa thanh toán
- **WHEN** user đặt hàng với phương thức thanh toán MoMo
- **AND** đơn hàng được tạo
- **BUT** user chưa hoàn tất thanh toán qua QR
- **THEN** hệ thống MUST NOT gửi local notification "Đặt hàng thành công"

#### Scenario: User đặt hàng với MoMo - thanh toán thành công
- **WHEN** user đặt hàng với phương thức thanh toán MoMo
- **AND** đơn hàng được tạo
- **AND** user quét QR và thanh toán thành công
- **AND** hệ thống xác nhận payment status là "success"
- **THEN** hệ thống gửi local notification "Đặt hàng thành công"
- **AND** schedule review reminder cho sản phẩm

#### Scenario: User đặt hàng với MoMo - thanh toán thất bại
- **WHEN** user đặt hàng với phương thức thanh toán MoMo
- **AND** đơn hàng được tạo
- **AND** thanh toán thất bại hoặc hết thời gian
- **THEN** hệ thống MUST NOT gửi local notification "Đặt hàng thành công"
