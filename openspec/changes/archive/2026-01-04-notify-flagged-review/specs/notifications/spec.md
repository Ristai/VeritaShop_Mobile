## MODIFIED Requirements

### Requirement: Automatic Notification Creation (from notifications spec)
Hệ thống SHALL tự động tạo notifications cho các sự kiện quan trọng của user.

#### Scenario: Notification when review is flagged
- **WHEN** user tạo hoặc cập nhật review và nội dung bị flag bởi moderation
- **THEN** hệ thống tạo notification với type "system"
- **AND** title là "Đánh giá đang chờ duyệt"
- **AND** message chứa tên sản phẩm

#### Scenario: Notification when review is rejected by admin
- **WHEN** admin reject review bị flag
- **THEN** hệ thống tạo notification cho user với type "system"
- **AND** title là "Đánh giá bị từ chối"
- **AND** message thông báo lý do (vi phạm quy định)

#### Scenario: Notification when flagged review is approved
- **WHEN** admin approve review đã bị flag
- **THEN** hệ thống tạo notification cho user với type "system"
- **AND** title là "Đánh giá đã được duyệt"
- **AND** message chứa tên sản phẩm
