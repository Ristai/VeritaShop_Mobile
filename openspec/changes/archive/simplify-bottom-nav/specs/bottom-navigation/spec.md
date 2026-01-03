# Bottom Navigation Specification

## Overview
Bottom Navigation Bar cho ứng dụng VeritaShop Mobile với 3 tab chính.

## MODIFIED Requirements

### REQ-NAV-001: Bottom Navigation Structure
Bottom Navigation Bar hiển thị 3 tab cố định ở cuối màn hình.

**Tabs:**
| Index | Label | Icon | Screen |
|-------|-------|------|--------|
| 0 | Trang chủ | `Icons.home` | HomeContent / ProductListScreen |
| 1 | Thông báo | `Icons.notifications_outlined` | NotificationsScreen |
| 2 | Cài đặt | `Icons.settings_outlined` | SettingsScreen |

#### Scenario: User navigates between tabs
**Given** user is on any tab
**When** user taps on a different tab icon
**Then** the corresponding screen is displayed
**And** the selected tab icon is highlighted with accent color
**And** unselected tabs show secondary text color

#### Scenario: App launches
**Given** user opens the app
**When** home screen loads after splash
**Then** Tab 0 (Trang chủ) is selected by default

---

## ADDED Requirements

### REQ-NOTIF-001: Notifications Screen
Màn hình hiển thị danh sách thông báo cho người dùng.

**Notification Types:**
- `order` - Thông báo đơn hàng (xác nhận, đang giao, hoàn thành, hủy)
- `promo` - Thông báo khuyến mãi (coupon mới, sản phẩm mới, flash sale)

#### Scenario: View all notifications
**Given** user is on Notifications tab
**When** screen loads
**Then** display list of all notifications sorted by timestamp (newest first)
**And** each notification shows: icon, title, message, relative time
**And** unread notifications have visual distinction (bold title or indicator dot)

#### Scenario: Filter notifications by type
**Given** user is on Notifications tab
**When** user selects filter "Đơn hàng"
**Then** only order-type notifications are displayed

**When** user selects filter "Khuyến mãi"
**Then** only promo-type notifications are displayed

#### Scenario: Mark notification as read
**Given** user has unread notifications
**When** user taps on a notification
**Then** notification is marked as read
**And** visual style updates to "read" state

#### Scenario: Empty state
**Given** user has no notifications
**When** Notifications screen loads
**Then** display empty state with illustration and message "Chưa có thông báo nào"

---

### REQ-NOTIF-002: Notification Model
Data model cho notification entity.

**Fields:**
```dart
class NotificationModel {
  final String id;
  final String type;        // 'order' | 'promo'
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;  // Optional payload (orderId, productId, etc.)
}
```

#### Scenario: Create order notification
**Given** system needs to notify about order update
**When** notification is created with type='order'
**Then** notification includes orderId in data field
**And** icon displayed is order-related (package, truck, check)

#### Scenario: Create promo notification
**Given** system needs to notify about promotion
**When** notification is created with type='promo'
**Then** notification includes relevant data (couponCode, productId)
**And** icon displayed is promo-related (discount, gift, new)

---

## REMOVED Requirements

### REQ-NAV-OLD-001: Analytics Tab (REMOVED)
~~Tab "Phân tích" với AnalyticsScreen~~ - Removed from bottom navigation.

### REQ-NAV-OLD-002: Comments Tab (REMOVED)
~~Tab "Bình luận" với CommentsScreen~~ - Removed from bottom navigation.
