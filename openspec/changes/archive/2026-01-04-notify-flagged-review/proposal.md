# Change: Notify user when review is flagged

## Why
Hiện tại khi bình luận của user bị flag do vi phạm nội dung, user không nhận được thông báo. User chỉ biết khi vào xem lại review thấy badge "Đang chờ duyệt". Cần gửi notification để user biết ngay review của họ đang được kiểm duyệt.

## What Changes
- **Backend**: Thêm notification khi review bị flag trong `reviewController.js`
- **Backend**: Thêm notification khi admin reject review trong `adminController.js`

## Impact
- Affected specs: notifications (modified)
- Affected code:
  - `backend/src/controllers/reviewController.js` - Thêm notification khi flag
  - `backend/src/controllers/adminController.js` - Thêm notification khi reject
