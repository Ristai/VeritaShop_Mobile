# review-moderation Specification

## Purpose
Tự động kiểm duyệt nội dung (text và hình ảnh) trong các đánh giá sản phẩm để phát hiện nội dung không phù hợp và thông báo cho admin xử lý.

## ADDED Requirements

### Requirement: Content Moderation Service
Hệ thống SHALL tích hợp external moderation API để kiểm tra nội dung đánh giá.

#### Scenario: Moderate text-only review
- **WHEN** user tạo review chỉ có text (không có images)
- **THEN** hệ thống gọi moderation API với format text-only
- **AND** lưu kết quả moderation vào review

#### Scenario: Moderate image-only review
- **WHEN** user tạo review chỉ có images (text rỗng hoặc minimal)
- **THEN** hệ thống gọi moderation API với format image URLs
- **AND** lưu kết quả moderation vào review

#### Scenario: Moderate review with both text and images
- **WHEN** user tạo review có cả text và images
- **THEN** hệ thống gọi moderation API với format combined (text + image_url objects)
- **AND** lưu kết quả moderation vào review

#### Scenario: Moderation API timeout or failure
- **WHEN** moderation API không phản hồi hoặc lỗi
- **THEN** review vẫn được tạo thành công
- **AND** moderationStatus được set là 'pending'
- **AND** hệ thống log lỗi để monitoring

### Requirement: Review Flagging
Hệ thống SHALL tự động đánh dấu review khi moderation phát hiện nội dung vi phạm.

#### Scenario: Review flagged for violation
- **WHEN** moderation API trả về `flagged: true`
- **THEN** review có `isFlagged: true` và `moderationStatus: 'pending'`
- **AND** chi tiết categories vi phạm được lưu trong `moderationResult`

#### Scenario: Review passes moderation
- **WHEN** moderation API trả về `flagged: false`
- **THEN** review có `isFlagged: false` và `moderationStatus: 'approved'`
- **AND** review hiển thị bình thường

### Requirement: Admin Flagged Review Management
Admin SHALL có khả năng xem và xử lý các reviews bị flag.

#### Scenario: View flagged reviews list
- **WHEN** admin chọn filter "Bị đánh dấu" trong review management
- **THEN** hiển thị danh sách reviews có `isFlagged: true`
- **AND** mỗi review hiển thị các categories vi phạm bằng tiếng Việt

#### Scenario: Admin approves flagged review
- **WHEN** admin click "Duyệt" trên flagged review
- **THEN** review `moderationStatus` thành 'approved'
- **AND** review hiển thị bình thường cho tất cả users

#### Scenario: Admin rejects flagged review
- **WHEN** admin click "Từ chối" trên flagged review
- **THEN** review `moderationStatus` thành 'rejected'
- **AND** review `isActive` thành false (soft delete)
- **AND** review không còn hiển thị cho public

### Requirement: Moderation Categories Vietnamese Translation
Hệ thống SHALL hiển thị các categories vi phạm bằng tiếng Việt cho admin.

#### Scenario: Display violation categories in Vietnamese
- **WHEN** admin xem chi tiết flagged review
- **THEN** các categories được hiển thị với tên tiếng Việt
- **AND** mapping bao gồm: harassment→Quấy rối, hate→Thù ghét, violence→Bạo lực, sexual→Nội dung người lớn, self-harm→Tự gây hại, illicit→Bất hợp pháp

### Requirement: User Review Status Display
Người dùng SHALL thấy trạng thái review của mình khi bị flag.

#### Scenario: User views their flagged review
- **WHEN** user xem review của mình đang bị flag
- **THEN** hiển thị badge "Đang chờ duyệt"
- **AND** review vẫn hiển thị cho chính user đó

#### Scenario: User views their rejected review
- **WHEN** user xem danh sách reviews của mình
- **THEN** reviews bị rejected không hiển thị trong list
