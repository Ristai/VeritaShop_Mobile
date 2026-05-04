## 1. Backend - Moderation Service
- [x] 1.1 Tạo `backend/src/utils/moderationService.js` với hàm `moderateContent(text, imageUrls)`
- [x] 1.2 Implement logic detect input type (text-only, image-only, combined)
- [x] 1.3 Implement API call đến `https://api2.honeysocial.click/api/moderate`
- [x] 1.4 Xử lý timeout và error với graceful degradation

## 2. Backend - Review Model Update
- [x] 2.1 Thêm fields vào `Review.js`: `isFlagged`, `moderationStatus`, `moderationResult`, `moderationNote`
- [x] 2.2 Thêm index cho `isFlagged` và `moderationStatus` để query hiệu quả

## 3. Backend - Review Controller Integration
- [x] 3.1 Cập nhật `createReview` để gọi moderation sau khi tạo review
- [x] 3.2 Cập nhật `updateReview` để re-moderate khi nội dung thay đổi
- [x] 3.3 Cập nhật `getProductReviews` để filter reviews theo moderationStatus nếu cần

## 4. Backend - Admin Endpoints
- [x] 4.1 Thêm endpoint `GET /api/admin/reviews/flagged` để lấy flagged reviews
- [x] 4.2 Thêm endpoint `PUT /api/admin/reviews/:id/moderation/approve` để approve
- [x] 4.3 Thêm endpoint `PUT /api/admin/reviews/:id/moderation/reject` để reject
- [x] 4.4 Cập nhật `getAllReviews` để hỗ trợ filter by `isFlagged`

## 5. Flutter - Model Update
- [x] 5.1 Cập nhật `review_model.dart` với fields moderation mới
- [x] 5.2 Thêm helper methods cho Vietnamese category names
- [x] 5.3 Thêm getter cho moderation status display

## 6. Flutter - Admin Repository
- [x] 6.1 Thêm method `getFlaggedReviews()` trong `admin_repository.dart`
- [x] 6.2 Thêm method `approveReviewModeration(id)`
- [x] 6.3 Thêm method `rejectReviewModeration(id, note)`

## 7. Flutter - Admin ViewModel
- [x] 7.1 Cập nhật `admin_review_view_model.dart` với state cho flagged filter
- [x] 7.2 Thêm methods `loadFlaggedReviews()`, `approveModeration()`, `rejectModeration()`
- [x] 7.3 Thêm computed property cho flagged count (badge)

## 8. Flutter - Admin UI
- [x] 8.1 Thêm filter chip "Bị đánh dấu" trong `admin_reviews_screen.dart`
- [x] 8.2 Tạo widget `ModerationCategoriesCard` hiển thị categories tiếng Việt
- [x] 8.3 Thêm actions "Duyệt" và "Từ chối" cho flagged reviews
- [x] 8.4 Hiển thị badge count cho flagged reviews trong navigation

## 9. Flutter - User-facing Display
- [x] 9.1 Cập nhật review card widget để hiển thị badge "Đang chờ duyệt" khi user xem review của mình
- [x] 9.2 Update `getMyReviews` display logic

## 10. Testing & Validation
- [ ] 10.1 Test moderation service với text-only input
- [ ] 10.2 Test moderation service với image-only input
- [ ] 10.3 Test moderation service với combined input
- [ ] 10.4 Test admin approve flow
- [ ] 10.5 Test admin reject flow
- [ ] 10.6 Test graceful degradation khi API fail
