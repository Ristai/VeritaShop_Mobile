## Context
VeritaShop cần tính năng content moderation để tự động phát hiện và đánh dấu nội dung không phù hợp trong các đánh giá sản phẩm. Hệ thống sẽ sử dụng external API `https://api2.honeysocial.click/api/moderate` hỗ trợ kiểm duyệt cả text và hình ảnh.

### Stakeholders
- **End Users**: Người mua hàng đăng đánh giá
- **Admin**: Quản lý và duyệt nội dung bị flag
- **Platform**: Đảm bảo môi trường an toàn cho users

### Constraints
- API external có thể timeout hoặc không khả dụng
- Moderation phải không block UX - review vẫn được tạo nhưng có thể bị pending
- Cần graceful degradation khi API fail

## Goals / Non-Goals

### Goals
- Tự động phát hiện nội dung vi phạm (text và/hoặc images)
- Thông báo admin khi có nội dung cần xem xét
- Cung cấp UI admin để quản lý flagged reviews
- Dịch các categories vi phạm sang tiếng Việt cho admin
- Hỗ trợ linh hoạt: text-only, image-only, hoặc cả hai

### Non-Goals
- Không tự động xóa review - luôn cần admin quyết định
- Không chặn người dùng đăng review - chỉ đánh dấu để xem xét
- Không lưu trữ lịch sử moderation chi tiết

## Decisions

### Decision 1: Moderation Flow - Non-blocking
**What**: Moderation chạy async sau khi review được tạo, không block UX
**Why**:
- Đảm bảo UX mượt mà cho user
- API external có thể chậm hoặc fail
- Tương tự pattern đã dùng cho ABSA sentiment analysis

**Alternatives considered**:
- Blocking moderation trước khi save: Reject vì làm chậm UX
- Queue-based moderation: Overcomplicated cho scope hiện tại

### Decision 2: Review Visibility khi bị Flag
**What**: Review vẫn hiển thị nhưng có badge "Đang chờ duyệt"
**Why**:
- Tránh false positives làm mất review hợp lệ
- Admin có thể nhanh chóng approve
- User biết review của họ đang được xem xét

**Alternatives considered**:
- Ẩn hoàn toàn: Có thể gây confusion cho user
- Pending approval trước khi hiện: Làm chậm feedback loop

### Decision 3: Smart Input Detection
**What**: Backend tự động detect loại input (text-only, image-only, hoặc cả hai) và gọi API tương ứng
**Why**:
- Đơn giản hóa logic phía client
- Tối ưu API calls - không gọi moderation cho fields trống
- Linh hoạt xử lý mọi case

### Decision 4: Admin UI - Integrated Tab
**What**: Thêm tab "Chờ duyệt" trong admin_reviews_screen hiện có
**Why**:
- Consistent với UI pattern hiện tại
- Không cần navigate đến screen mới
- Admin có thể toggle giữa all/approved/pending/flagged

## Data Model Changes

### Review Schema Additions
```javascript
// Moderation fields
isFlagged: {
  type: Boolean,
  default: false,
},
moderationStatus: {
  type: String,
  enum: ['pending', 'approved', 'rejected'],
  default: 'approved',
},
moderationResult: {
  id: String,
  model: String,
  flagged: Boolean,
  categories: {
    harassment: Boolean,
    'harassment/threatening': Boolean,
    hate: Boolean,
    'hate/threatening': Boolean,
    illicit: Boolean,
    'illicit/violent': Boolean,
    'self-harm': Boolean,
    'self-harm/intent': Boolean,
    'self-harm/instructions': Boolean,
    sexual: Boolean,
    'sexual/minors': Boolean,
    violence: Boolean,
    'violence/graphic': Boolean,
  },
  categoryScores: {
    harassment: Number,
    // ... other scores
  },
  checkedAt: Date,
},
moderationNote: String, // Admin note khi approve/reject
```

## API Design

### Admin Endpoints
```
GET  /api/admin/reviews/flagged     - Lấy danh sách flagged reviews
PUT  /api/admin/reviews/:id/approve - Approve review (moderationStatus = 'approved')
PUT  /api/admin/reviews/:id/reject  - Reject review (isActive = false, moderationStatus = 'rejected')
```

## Risks / Trade-offs

### Risk 1: External API Unavailability
- **Risk**: API moderation có thể down hoặc timeout
- **Mitigation**: Graceful degradation - review được tạo với `moderationStatus: 'pending'`, retry later

### Risk 2: False Positives
- **Risk**: Nội dung hợp lệ bị flag
- **Mitigation**: Không auto-hide, admin review và approve nhanh chóng

### Risk 3: API Cost/Rate Limits
- **Risk**: Tốn chi phí hoặc bị rate limit
- **Mitigation**: Chỉ moderate khi có content (skip empty text/images)

## Migration Plan
1. Deploy backend changes với moderation disabled
2. Test moderation service với sample data
3. Enable moderation cho new reviews
4. Existing reviews không cần backfill (grandfather clause)
5. Rollback: Set `MODERATION_ENABLED=false` trong env

## Open Questions
- [ ] Có cần retry mechanism khi moderation API fail không? → Recommend: Yes, simple retry 1 lần
- [ ] Có notification cho admin khi có flagged review không? → Recommend: Badge count trong sidebar đủ
