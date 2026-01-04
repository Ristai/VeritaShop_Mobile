# notifications Specification

## Purpose
TBD - created by archiving change replace-notification-mockdata. Update Purpose after archive.
## Requirements
### Requirement: Notification Persistence
The system SHALL store user notifications in MongoDB database to enable persistent access across sessions and devices.

#### Scenario: Notification stored after order creation
- **WHEN** user successfully places an order (COD or MoMo payment)
- **THEN** a notification is created and stored in database
- **AND** notification contains order ID, title, message, and timestamp

#### Scenario: Notification persists across app restarts
- **WHEN** user closes and reopens the app
- **THEN** previously received notifications are still available
- **AND** notifications are fetched from server

### Requirement: Notification API
The system SHALL provide REST API endpoints for notification management.

#### Scenario: Fetch user notifications
- **WHEN** authenticated user requests their notifications
- **THEN** system returns paginated list of notifications
- **AND** notifications are sorted by creation date (newest first)
- **AND** response includes unread count

#### Scenario: Mark notification as read
- **WHEN** user opens/taps a notification
- **THEN** notification isRead status is updated to true
- **AND** unread count decreases

#### Scenario: Mark all notifications as read
- **WHEN** user selects "Mark all as read"
- **THEN** all user's unread notifications are marked as read
- **AND** unread count becomes zero

#### Scenario: Delete notification
- **WHEN** user deletes a notification
- **THEN** notification is removed from database
- **AND** notification no longer appears in list

### Requirement: Automatic Notification Creation
The system SHALL automatically create notifications for key user events.

#### Scenario: Order placed notification
- **WHEN** user successfully creates an order
- **THEN** system creates notification with type "order"
- **AND** title includes "Đặt hàng thành công"
- **AND** message includes order number

#### Scenario: Order status change notification
- **WHEN** order status changes (processing, shipped, delivered, cancelled)
- **THEN** system creates notification for order owner
- **AND** notification type is "order"
- **AND** message reflects new status

#### Scenario: Review flagged notification
- **WHEN** user creates or updates a review and content is flagged by moderation
- **THEN** system creates notification with type "system"
- **AND** title is "Đánh giá đang chờ duyệt"
- **AND** message contains product name

#### Scenario: Review rejected notification
- **WHEN** admin rejects a flagged review
- **THEN** system creates notification for user with type "system"
- **AND** title is "Đánh giá bị từ chối"
- **AND** message indicates violation of guidelines

#### Scenario: Review approved notification
- **WHEN** admin approves a flagged review
- **THEN** system creates notification for user with type "system"
- **AND** title is "Đánh giá đã được duyệt"
- **AND** message contains product name

### Requirement: Notification Filtering
The system SHALL support filtering notifications by type.

#### Scenario: Filter by order notifications
- **WHEN** user selects "Đơn hàng" filter
- **THEN** only notifications with type "order" are displayed

#### Scenario: Filter by promo notifications
- **WHEN** user selects "Khuyến mãi" filter
- **THEN** only notifications with type "promo" are displayed

#### Scenario: Show all notifications
- **WHEN** user selects "Tất cả" filter
- **THEN** all notification types are displayed

### Requirement: Notification Data Cleanup
The system SHALL automatically remove old notifications to manage storage.

#### Scenario: Auto-delete old notifications
- **WHEN** notification is older than 30 days
- **THEN** notification is automatically deleted from database
- **AND** deleted notification no longer appears to user

