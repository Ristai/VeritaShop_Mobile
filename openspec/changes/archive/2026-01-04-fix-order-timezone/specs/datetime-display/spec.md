# datetime-display Specification

## Purpose
Đảm bảo tất cả datetime trong app hiển thị đúng timezone UTC+7 (Asia/Ho_Chi_Minh) - múi giờ Việt Nam.

## ADDED Requirements

### Requirement: DATETIME-001 - Vietnam Timezone Display
Tất cả datetime hiển thị trong app MUST sử dụng timezone UTC+7 (Vietnam).

DateTime từ API (MongoDB UTC) MUST được convert sang UTC+7 trước khi hiển thị cho user.

#### Scenario: Order creation time display
- **WHEN** user views order in Order History screen
- **THEN** `createdAt` timestamp MUST display in UTC+7 timezone
- **AND** format MUST be `dd/MM/yyyy HH:mm`
- **EXAMPLE** Order created at `2026-01-04T08:00:00Z` (UTC) displays as `04/01/2026 15:00` (UTC+7)

#### Scenario: Admin views order time
- **WHEN** admin views order in Admin Orders screen
- **THEN** order timestamp MUST display in UTC+7 timezone
- **AND** format MUST be `dd/MM/yyyy HH:mm`

#### Scenario: Order detail shows correct time
- **WHEN** user views order detail
- **THEN** order creation time MUST display in UTC+7
- **AND** status change times (confirmedAt, shippingAt, etc.) MUST display in UTC+7

### Requirement: DATETIME-002 - Centralized Date Formatter
App MUST have centralized date formatting utility để ensure consistency.

Utility MUST provide:
- `toVietnamTime(DateTime utc)` - Convert UTC to UTC+7
- `formatVietnamDateTime(DateTime date)` - Format as `dd/MM/yyyy HH:mm`
- `formatVietnamDate(DateTime date)` - Format as `dd/MM/yyyy`

#### Scenario: Developer formats datetime
- **WHEN** developer needs to display datetime
- **THEN** developer MUST use centralized formatter from `lib/core/utils/date_formatter.dart`
- **AND** MUST NOT create local `_formatDate()` functions

### Requirement: DATETIME-003 - Admin Dashboard Timezone
Admin dashboard charts và reports MUST hiển thị data theo timezone Việt Nam.

#### Scenario: Admin views daily sales report
- **WHEN** admin views sales report for "Hôm nay"
- **THEN** report MUST include orders from 00:00 - 23:59 UTC+7
- **AND** NOT from 00:00 - 23:59 UTC
