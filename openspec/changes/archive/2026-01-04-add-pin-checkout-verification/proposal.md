# Change: Thêm xác thực PIN khi đặt hàng

## Why
Tăng cường bảo mật cho giao dịch đặt hàng bằng cách yêu cầu người dùng xác thực mã PIN trước khi hoàn tất đơn hàng. Điều này giúp ngăn chặn việc đặt hàng trái phép khi thiết bị bị mất hoặc bị người khác sử dụng.

## What Changes
- Thêm bước xác thực PIN trước khi gọi API đặt hàng trong checkout flow
- Hiển thị PIN dialog/bottom sheet khi user nhấn "Đặt hàng" (nếu PIN đã được bật)
- Nếu user chưa enable PIN → bỏ qua bước xác thực, đặt hàng bình thường
- Nếu user đã enable PIN → yêu cầu nhập PIN đúng mới cho phép đặt hàng
- Tái sử dụng PinViewModel và PinService đã có sẵn

## Impact
- Affected specs: `checkout`
- Affected code:
  - `lib/presentation/screens/checkout_screen.dart` - Thêm logic xác thực PIN trong `_placeOrder()`
  - Tái sử dụng `lib/presentation/view_models/pin_view_model.dart`
  - Tái sử dụng `lib/presentation/widgets/pin_input.dart`
