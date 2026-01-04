# Change: Fix MoMo Payment Notification Timing

## Why
Hiện tại khi người dùng chọn thanh toán MoMo, hệ thống gửi local notification "Đặt hàng thành công" ngay sau khi tạo đơn hàng, trước khi người dùng hoàn tất quét QR và thanh toán. Điều này gây hiểu nhầm vì đơn hàng chưa thực sự được thanh toán thành công.

## What Changes
- **MODIFIED**: Logic gửi notification đặt hàng thành công trong `OrderViewModel.placeOrder()` chỉ áp dụng cho phương thức COD
- **ADDED**: Gửi notification đặt hàng thành công cho MoMo sau khi thanh toán được xác nhận thành công trong `PaymentProcessingScreen._onPaymentSuccess()`

## Impact
- Affected specs: `checkout`
- Affected code:
  - `lib/presentation/view_models/order_view_model.dart:197-206`
  - `lib/presentation/screens/payment_processing_screen.dart:69-80`
  - `lib/presentation/screens/checkout_screen.dart:117-121` (để truyền payment method)
