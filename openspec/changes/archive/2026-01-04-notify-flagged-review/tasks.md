## 1. Backend Implementation

- [x] 1.1 Update reviewController.js - createReview
  - Thêm notification khi review bị flag sau moderation
  - Title: "Đánh giá đang chờ duyệt"
  - Message: "Đánh giá của bạn cho [product name] đang được kiểm duyệt."

- [x] 1.2 Update reviewController.js - updateReview
  - Thêm notification khi review bị flag sau re-moderation
  - Chỉ gửi notification nếu review từ approved -> flagged

- [x] 1.3 Update adminController.js - rejectReviewModeration
  - Thêm notification khi admin reject review
  - Title: "Đánh giá bị từ chối"
  - Message: "Đánh giá của bạn cho [product name] đã bị từ chối do vi phạm quy định."

- [x] 1.4 Update adminController.js - approveReviewModeration
  - Thêm notification khi admin approve review đã bị flag
  - Title: "Đánh giá đã được duyệt"
  - Message: "Đánh giá của bạn cho [product name] đã được duyệt."
