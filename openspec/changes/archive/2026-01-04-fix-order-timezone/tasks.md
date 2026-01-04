# Tasks: Fix Order Timezone

## Implementation Tasks

- [x] **TASK-1**: Create centralized date formatter utility
  - Create `lib/core/utils/date_formatter.dart`
  - Add `toVietnamTime(DateTime utc)` function (+7 hours offset)
  - Add `formatVietnamDateTime(DateTime date)` for consistent format `dd/MM/yyyy HH:mm`
  - Add `formatVietnamDate(DateTime date)` for date only `dd/MM/yyyy`

- [x] **TASK-2**: Update Order History Screen
  - Replace `_formatDate()` to use centralized formatter
  - Ensure all datetime displays use Vietnam timezone

- [x] **TASK-3**: Update Admin Orders Screen
  - Replace `_formatDate()` to use centralized formatter
  - Apply to order list and order detail views

- [x] **TASK-4**: Update Admin Dashboard Screen
  - Check and update any datetime displays
  - Ensure chart data uses correct timezone

- [x] **TASK-5**: Update Admin Reports Screen
  - Update report date displays
  - Ensure date filters use correct timezone

- [x] **TASK-6**: Verify other screens with datetime
  - Check notifications, reviews, comments
  - Updated: admin_reviews_screen.dart, admin_users_screen.dart, admin_coupons_screen.dart

## Validation
- [x] Run `flutter analyze` to check for errors - PASSED (only pre-existing warnings)
