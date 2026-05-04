# Proposal: Fix Order Timezone to UTC+7 (Ho Chi Minh)

## Problem Statement
Hiện tại, thời gian đơn hàng (`createdAt`, `updatedAt`) trong app đang hiển thị sai timezone. MongoDB lưu thời gian dưới dạng UTC, và Flutter app không convert sang UTC+7 (Asia/Ho_Chi_Minh) khi hiển thị.

Ví dụ: Đơn hàng tạo lúc 15:00 UTC+7 hiển thị là 08:00 (UTC).

## Proposed Solution
Convert tất cả DateTime từ API sang UTC+7 trước khi hiển thị. Áp dụng cho:

1. **Order History Screen**: Hiển thị thời gian tạo đơn hàng
2. **Admin Orders Screen**: Hiển thị thời gian đơn hàng trong dashboard
3. **Order Detail**: Thời gian chi tiết đơn hàng
4. **Tất cả các screens khác có hiển thị timestamp**

### Approach
- Tạo utility function `toVietnamTime(DateTime utc)` để convert UTC -> UTC+7
- Cập nhật tất cả các hàm `_formatDate()` trong app để sử dụng UTC+7
- Sử dụng `intl` package (đã có sẵn) để format datetime

### Files Affected
- `lib/core/utils/date_formatter.dart` (new - centralized date formatting)
- `lib/presentation/screens/order_history_screen.dart`
- `lib/presentation/screens/admin/admin_orders_screen.dart`
- `lib/presentation/screens/admin/admin_dashboard_screen.dart`
- `lib/presentation/screens/admin/admin_reports_screen.dart`
- `lib/data/models/order_model.dart`

## Benefits
- Thời gian hiển thị đúng với timezone Việt Nam
- Centralized date formatting để dễ maintain
- Consistent format across all screens
