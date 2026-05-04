# Change: Cải thiện giao diện Checkout và Format giá tiền toàn app

## Why
Trang checkout và toàn bộ app có các vấn đề:
1. Hiển thị quá nhiều phương thức thanh toán không cần thiết (VNPay, ZaloPay, Card) - chỉ cần MoMo và COD
2. Giao diện checkout sử dụng hardcoded dark theme colors, không tương thích tốt với light mode
3. Format giá tiền không theo chuẩn Việt Nam (đang dùng `200K đ` thay vì `200.000 VND`) - cần thay đổi đồng bộ trên toàn app

## What Changes
- **Payment Methods**: Loại bỏ VNPay, ZaloPay, Card - chỉ giữ lại COD và MoMo
- **Light Mode UI**: Cập nhật tất cả các component trong checkout_screen.dart sử dụng dynamic colors từ `AppColors.of(context)` thay vì hardcoded dark theme constants
- **Price Format (Toàn app)**: Đổi format giá từ `200K đ` sang `200.000 VND` theo chuẩn Việt Nam - áp dụng cho tất cả screens và models

## Impact
- Affected specs: checkout (new capability)
- Affected code:
  - `lib/presentation/view_models/order_view_model.dart` - cập nhật danh sách payment methods
  - `lib/presentation/screens/checkout_screen.dart` - cập nhật UI colors và price format
  - `lib/presentation/screens/order_history_screen.dart` - price format
  - `lib/presentation/screens/order_success_screen.dart` - price format
  - `lib/presentation/screens/admin/admin_dashboard_screen.dart` - price format
  - `lib/presentation/screens/admin/admin_reports_screen.dart` - price format
  - `lib/data/models/product_model.dart` - price format helper methods
  - `lib/data/models/coupon_model.dart` - price format helper
