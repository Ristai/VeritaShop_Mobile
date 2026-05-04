## 1. Flutter App - WriteReviewScreen UI
- [x] 1.1 Thêm state quản lý danh sách ảnh đã chọn (`List<XFile>`)
- [x] 1.2 Thêm UI section "Thêm hình ảnh" với grid hiển thị ảnh preview
- [x] 1.3 Thêm nút "+" để chọn ảnh từ gallery hoặc camera
- [x] 1.4 Thêm nút xóa ảnh cho mỗi ảnh đã chọn
- [x] 1.5 Giới hạn tối đa 5 ảnh và hiển thị thông báo khi đạt giới hạn

## 2. Flutter App - Image Upload Logic
- [x] 2.1 Tạo method `_uploadImages()` để upload danh sách ảnh lên server
- [x] 2.2 Cập nhật `_submitReview()` để upload ảnh trước, sau đó gửi URLs trong request tạo review
- [x] 2.3 Thêm progress indicator khi đang upload ảnh
- [x] 2.4 Xử lý lỗi upload (hiển thị thông báo, retry option)

## 3. Flutter App - Review Repository
- [x] 3.1 Cập nhật `createReview()` để truyền `images` parameter (đã có, verified)
- [x] 3.2 Sử dụng `ApiService.uploadImages()` có sẵn để upload ảnh

## 4. Flutter App - Display Review Images
- [x] 4.1 Cập nhật `_buildReviewItemFromModel()` trong `ProductDetailScreen` để hiển thị ảnh
- [x] 4.2 Thêm horizontal scrollable list cho hình ảnh của review
- [x] 4.3 Thêm chức năng tap để xem ảnh full screen (tái sử dụng `ImageZoomViewer`)

## 5. Validation & Testing
- [x] 5.1 flutter analyze passed (no errors)
- [ ] 5.2 Test chọn ảnh từ gallery - Manual testing required
- [ ] 5.3 Test upload ảnh lên Cloudinary - Manual testing required
- [ ] 5.4 Test hiển thị ảnh trong review - Manual testing required
