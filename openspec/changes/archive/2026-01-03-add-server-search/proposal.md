# Server-side Product Search

## Summary
Chuyển đổi chức năng search sản phẩm từ local filtering sang server-side search, tận dụng API backend để cải thiện hiệu suất và chất lượng kết quả tìm kiếm.

## Motivation
Hiện tại, app đang load toàn bộ sản phẩm và filter trên client. Điều này gây ra:
- **Hiệu suất kém**: Phải tải tất cả sản phẩm trước khi search
- **Kết quả không tối ưu**: Chỉ search theo tên và mô tả local
- **Không scale**: Khi có nhiều sản phẩm, client phải xử lý nhiều data

Server-side search giúp:
- Search nhanh hơn với database indexing
- Hỗ trợ full-text search tiếng Việt
- Pagination cho kết quả search
- Giảm bandwidth và memory trên client

## Scope
- **In scope**:
  - Thay đổi ProductListScreen để gọi API search
  - Cập nhật ProductViewModel/Repository để hỗ trợ search state
  - Debounce search để tránh gọi API quá nhiều
  - Loading state cho search
- **Out of scope**:
  - Advanced filters (sẽ là feature riêng)
  - Voice search
  - Search analytics

## Dependencies
- Backend API endpoint `/products/search` đã có sẵn
- Package `rxdart` cho debounce (hoặc dùng Timer)
