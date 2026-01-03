# Change: Thêm Content Moderation cho Bình luận/Đánh giá Sản phẩm

## Why
Hiện tại hệ thống cho phép người dùng đăng đánh giá sản phẩm với text và hình ảnh mà không có kiểm duyệt nội dung. Điều này có thể dẫn đến việc xuất hiện nội dung không phù hợp (bạo lực, khiêu dâm, thù ghét, quấy rối, v.v.) trên nền tảng. Cần tích hợp API moderation để tự động phát hiện và đánh dấu nội dung vi phạm, thông báo cho admin để xử lý.

## What Changes

### Backend
- Tạo service `moderationService.js` để gọi API `/api/moderate` từ `https://api2.honeysocial.click`
- Cập nhật `reviewController.js` để gọi moderation khi tạo/cập nhật review
- Thêm schema fields mới vào Review model: `moderationResult`, `isFlagged`, `moderationCategories`
- Thêm endpoints admin để quản lý reviews bị flag
- Hỗ trợ 3 loại input: text-only, image-only, hoặc cả hai

### Admin Dashboard (Flutter)
- Thêm tab/screen quản lý reviews bị flag
- Hiển thị thông tin moderation với các categories được dịch sang tiếng Việt
- Cho phép admin duyệt (approve) hoặc xóa (reject) reviews bị flag
- Badge hiển thị số lượng reviews đang chờ xử lý

### Mobile App
- Hiển thị thông báo khi review bị flag và đang chờ duyệt
- Cập nhật trạng thái review phù hợp

## Impact
- Affected specs: `admin-management` (cần thêm requirement cho flagged review management)
- Affected code:
  - `backend/src/models/Review.js` - Thêm moderation fields
  - `backend/src/controllers/reviewController.js` - Tích hợp moderation
  - `backend/src/controllers/adminController.js` - Endpoints quản lý flagged reviews
  - `backend/src/utils/moderationService.js` - Service mới
  - `lib/presentation/screens/admin/` - UI admin cho flagged reviews
  - `lib/data/models/review_model.dart` - Cập nhật model

## API Integration Details

### API Endpoint
- **URL**: `https://api2.honeysocial.click/api/moderate`
- **Method**: POST

### Request Formats

**Text-only:**
```json
{
  "input": "Nội dung cần kiểm tra"
}
```

**Image-only:**
```json
{
  "input": [
    {
      "type": "image_url",
      "image_url": {
        "url": "https://example.com/image.jpg"
      }
    }
  ]
}
```

**Text + Images:**
```json
{
  "input": [
    {
      "type": "text",
      "text": "Mô tả nội dung"
    },
    {
      "type": "image_url",
      "image_url": {
        "url": "https://example.com/image.jpg"
      }
    }
  ]
}
```

### Response Format
```json
{
  "success": true,
  "id": "modr-xxx",
  "model": "omni-moderation-latest",
  "results": [
    {
      "flagged": true,
      "categories": {
        "harassment": true,
        "harassment/threatening": false,
        "hate": false,
        "hate/threatening": false,
        "illicit": false,
        "illicit/violent": false,
        "self-harm": false,
        "self-harm/intent": false,
        "self-harm/instructions": false,
        "sexual": false,
        "sexual/minors": false,
        "violence": false,
        "violence/graphic": false
      },
      "category_scores": { ... }
    }
  ]
}
```

## Moderation Categories (Vietnamese Translation)
| Category | Tiếng Việt |
|----------|-----------|
| harassment | Quấy rối |
| harassment/threatening | Quấy rối/Đe dọa |
| hate | Thù ghét |
| hate/threatening | Thù ghét/Đe dọa |
| illicit | Bất hợp pháp |
| illicit/violent | Bất hợp pháp/Bạo lực |
| self-harm | Tự gây hại |
| self-harm/intent | Tự gây hại/Ý định |
| self-harm/instructions | Tự gây hại/Hướng dẫn |
| sexual | Nội dung người lớn |
| sexual/minors | Nội dung trẻ em |
| violence | Bạo lực |
| violence/graphic | Bạo lực/Hình ảnh |
