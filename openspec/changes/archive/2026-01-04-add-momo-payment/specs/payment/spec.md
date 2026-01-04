# Payment Capability Specification

## Overview

Định nghĩa các yêu cầu cho hệ thống thanh toán trong VeritaShop, bao gồm tích hợp MoMo và các phương thức thanh toán khác.

---

## ADDED Requirements

### Requirement: Create MoMo Payment

The system MUST allow creating MoMo payment requests for orders. Hệ thống phải cho phép tạo yêu cầu thanh toán MoMo cho đơn hàng.

**Priority**: High

#### Scenario: User creates MoMo payment for order

**Given**: User đã đăng nhập và có đơn hàng chưa thanh toán
**When**: User gọi API `POST /api/payments/momo/create` với orderId và amount
**Then**:
- Hệ thống tạo signature theo format MoMo
- Gọi MoMo API `/v2/gateway/api/create` với requestType `captureWallet`
- Lưu Payment record với status `pending`
- Trả về `payUrl` và `deeplink` cho frontend

#### Scenario: Create payment for already paid order

**Given**: User có đơn hàng đã thanh toán
**When**: User gọi API create payment
**Then**: Trả về lỗi 400 với message "Đơn hàng đã được thanh toán"

#### Scenario: Create payment for order not belonging to user

**Given**: User cố tạo payment cho đơn hàng của user khác
**When**: User gọi API create payment
**Then**: Trả về lỗi 403 với message "Không có quyền truy cập đơn hàng này"

---

### Requirement: Handle MoMo IPN Callback

The system MUST handle IPN callbacks from MoMo to update payment status. Hệ thống phải xử lý IPN callback từ MoMo để cập nhật trạng thái thanh toán.

**Priority**: High

#### Scenario: Receive successful payment IPN

**Given**: User đã thanh toán thành công trên MoMo
**When**: MoMo gửi IPN với `resultCode = 0`
**Then**:
- Verify signature khớp
- Cập nhật Payment status = `success`
- Cập nhật Order paymentStatus = `paid`
- Cập nhật Order status = `pending` (chờ xử lý)
- Clear cart của user
- Trả về HTTP 204 cho MoMo

#### Scenario: Receive failed payment IPN

**Given**: User hủy hoặc thanh toán thất bại
**When**: MoMo gửi IPN với `resultCode != 0`
**Then**:
- Verify signature khớp
- Cập nhật Payment status = `failed`
- Cập nhật Payment resultCode và message
- Giữ nguyên Order status
- Trả về HTTP 204 cho MoMo

#### Scenario: Invalid IPN signature

**Given**: Nhận request giả mạo
**When**: Signature không khớp
**Then**:
- Log security warning
- Trả về HTTP 400
- Không cập nhật database

---

### Requirement: Query Payment Status

The system MUST allow querying payment status for orders. Hệ thống phải cho phép kiểm tra trạng thái thanh toán.

**Priority**: Medium

#### Scenario: Query pending payment status

**Given**: Payment đang ở trạng thái pending
**When**: User gọi API `GET /api/payments/momo/status/:orderId`
**Then**:
- Gọi MoMo query API để lấy status mới nhất
- Cập nhật Payment record nếu có thay đổi
- Trả về status hiện tại

#### Scenario: Query completed payment status

**Given**: Payment đã success hoặc failed
**When**: User gọi API query status
**Then**: Trả về status từ database, không gọi MoMo API

---

### Requirement: Store Payment Transaction

The system MUST store payment transaction information. Hệ thống phải lưu trữ thông tin giao dịch thanh toán.

**Priority**: High

#### Scenario: Create payment record

**Given**: User khởi tạo thanh toán MoMo
**When**: Gọi MoMo API thành công
**Then**: Lưu Payment record với các thông tin:
- `order`: ObjectId của đơn hàng
- `user`: ObjectId của người dùng
- `method`: "momo"
- `requestId`: ID unique cho request
- `momoOrderId`: OrderId gửi cho MoMo
- `amount`: Số tiền
- `status`: "pending"
- `payUrl`: URL thanh toán
- `deeplink`: Deep link đến MoMo app
- `createdAt`: Timestamp

---

### Requirement: Mobile Deep Link Integration

The Flutter app MUST handle deep link callbacks from MoMo. Ứng dụng Flutter phải xử lý deep link callback từ MoMo.

**Priority**: High

#### Scenario: Open MoMo app via deep link

**Given**: User nhận được payUrl và deeplink từ backend
**When**: User chọn thanh toán
**Then**:
- Thử mở MoMo app qua deeplink
- Nếu không có MoMo app, mở payUrl trong WebView
- Hiển thị loading screen

#### Scenario: Receive callback after payment

**Given**: User hoàn tất flow trên MoMo
**When**: MoMo redirect về `veritashop://momo-return`
**Then**:
- Parse URL parameters
- Gọi API check status
- Navigate đến màn hình kết quả phù hợp

---

## MODIFIED Requirements

### Requirement: Place Order with Payment Method

The system MUST support different order flows based on payment method. Hệ thống phải hỗ trợ các flow đặt hàng khác nhau dựa trên phương thức thanh toán.

#### Scenario: Place order with MoMo payment

**Given**: User có cart và chọn payment method = "MoMo"
**When**: User gọi API `POST /api/orders`
**Then**:
- Tạo order với `status = "pending_payment"`
- Tạo order với `paymentStatus = "pending"`
- KHÔNG clear cart (chờ payment success)
- KHÔNG gửi email xác nhận
- Trả về orderId để frontend tạo payment

#### Scenario: Place order with COD (unchanged)

**Given**: User có cart và chọn payment method = "COD"
**When**: User gọi API `POST /api/orders`
**Then**: Giữ nguyên flow hiện tại (clear cart, gửi email)

---

## Technical Notes

### MoMo API v2 Endpoints

| Environment | Base URL |
|-------------|----------|
| Sandbox | `https://test-payment.momo.vn` |
| Production | `https://payment.momo.vn` |

### Signature Format

```
rawSignature = "accessKey=" + accessKey
  + "&amount=" + amount
  + "&extraData=" + extraData
  + "&ipnUrl=" + ipnUrl
  + "&orderId=" + orderId
  + "&orderInfo=" + orderInfo
  + "&partnerCode=" + partnerCode
  + "&redirectUrl=" + redirectUrl
  + "&requestId=" + requestId
  + "&requestType=" + requestType

signature = HMAC_SHA256(rawSignature, secretKey)
```

### Result Codes Reference

| Code | Category | Description |
|------|----------|-------------|
| 0 | Success | Giao dịch thành công |
| 9000 | Processing | Giao dịch đang xử lý |
| 10-19 | User Error | Lỗi từ phía người dùng |
| 20-29 | System Error | Lỗi hệ thống MoMo |
| 30-39 | Partner Error | Lỗi cấu hình partner |
