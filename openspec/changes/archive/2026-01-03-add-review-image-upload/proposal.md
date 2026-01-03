# Change: Add Review Image Upload to Cloudinary

## Why
Hiện tại khi người dùng đánh giá sản phẩm trên trang chi tiết sản phẩm, họ chỉ có thể nhập tiêu đề và nội dung bình luận. Việc cho phép người dùng upload hình ảnh sản phẩm sẽ giúp các đánh giá trở nên trực quan và đáng tin cậy hơn, cải thiện trải nghiệm mua sắm cho khách hàng khác.

## What Changes
- **Flutter App**:
  - Thêm UI cho việc chọn và xem trước hình ảnh trong `WriteReviewScreen`
  - Tích hợp `image_picker` để chọn ảnh từ thư viện hoặc camera
  - Upload hình ảnh lên server trước khi gửi review
  - Hiển thị hình ảnh trong danh sách review trên `ProductDetailScreen`

- **Backend**:
  - Tận dụng endpoint `/api/upload/images` đã có sẵn để upload ảnh review lên Cloudinary
  - Review model đã hỗ trợ field `images: [String]` - không cần thay đổi schema

## Impact
- Affected specs: Cần tạo spec mới `review-images`
- Affected code:
  - `lib/presentation/screens/write_review_screen.dart` - Thêm UI upload ảnh
  - `lib/presentation/screens/product_detail_screen.dart` - Hiển thị ảnh trong review
  - `lib/data/repositories/review_repository.dart` - Truyền images khi tạo review
  - `lib/core/network/api_service.dart` - Đã có endpoint `uploadImages`
  - Backend không cần thay đổi - đã đầy đủ chức năng

## Out of Scope
- Không thay đổi giới hạn số ảnh (giữ nguyên max 5 ảnh từ upload endpoint)
- Không thêm chức năng chỉnh sửa ảnh (crop, filter)
- Không thay đổi schema Review model (đã có sẵn field images)
