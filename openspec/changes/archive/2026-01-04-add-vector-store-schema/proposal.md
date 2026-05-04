# Change: Add Document Generation for OpenAI File Search Integration

## Why

Hệ thống chatbot e-commerce cần tích hợp với OpenAI File Search (Vector Store) để hỗ trợ truy vấn ngữ nghĩa thông minh. Dữ liệu hiện tại được lưu trữ trong các collection riêng biệt (Product, Review, Coupon) dẫn đến:

1. **Context fragmentation** - Thông tin sentiment analysis từ reviews không liên kết trực tiếp với product
2. **Inefficient retrieval** - Để trả lời "điện thoại nào có pin tốt nhất đang khuyến mãi", cần nhiều sources
3. **Manual data preparation** - Không có cách tự động tạo documents cho File Search

**Giải pháp**: Tạo document files (JSON) từ MongoDB data để upload lên OpenAI Vector Store thông qua File Search API.

## What Changes

### New Capability: File Search Document Generation

- **ADDED** Document schema cho file generation - kết hợp Product + ABSA Reviews + Active Coupons
- **ADDED** File generator tạo `.json` files với metadata attributes cho filtering
- **ADDED** Script export từ MongoDB sang files để upload lên OpenAI Vector Store
- **ADDED** Data timestamp để LLM biết thông tin cập nhật đến thời điểm nào

### Key Design Decisions

1. **JSON File Format** - Sử dụng JSON files với structured content để OpenAI File Search có thể parse và index
2. **Metadata Attributes** - Tận dụng OpenAI Vector Store attributes cho filtering (brand, price_range, aspect scores)
3. **Pre-aggregated Data** - Tính toán sẵn sentiment scores từ reviews thật trong database
4. **All Reviews + Featured Reviews** - Export tất cả reviews từ DB (max 50) + subset featured reviews (max 15)
5. **Data Freshness Notice** - Thêm `data_updated_at` và `data_notice` để LLM thông báo cho user biết data không phải real-time
6. **Manual Upload Flow** - Export files locally, upload thủ công qua OpenAI website/API

### Document Structure

```json
{
  "product_id": "...",
  "generated_at": "2026-01-05T03:30:00.000Z",
  "data_updated_at": "10:30 ngày 05/01/2026",
  "data_notice": "Thông tin sản phẩm được cập nhật đến 10:30 ngày 05/01/2026. Dữ liệu có thể đã thay đổi sau thời điểm này.",
  "product_info": { ... },
  "sentiment_summary": { ... },
  "all_reviews": [ ... ],
  "featured_reviews": [ ... ],
  "active_coupons": [ ... ],
  "searchable_content": "..."
}
```

### Workflow

```
MongoDB Data → Export Script → JSON Files → Upload to OpenAI → File Search Ready
```

## Impact

- **Affected specs**:
  - `review-sentiment` - Sử dụng dữ liệu ABSA đã có
- **Affected code**:
  - `backend/src/scripts/exportFileSearch.js` - Export script với CLI arguments
  - `backend/src/services/fileSearchExport/` - Document generation service
    - `documentGenerator.js` - Main generator logic
    - `sentimentAggregator.js` - Aggregate reviews by aspect
    - `reviewSelector.js` - Select all reviews + featured reviews
    - `couponMatcher.js` - Match applicable coupons
    - `contentFormatter.js` - Generate searchable_content text
- **New dependencies**:
  - Không cần OpenAI SDK (upload thủ công)
- **Output**:
  - `exports/{date}/products/` - JSON files cho mỗi product
  - `exports/{date}/attributes_schema.json` - Schema cho Vector Store attributes
  - `exports/{date}/manifest.json` - List files với metadata for bulk upload
  - `exports/{date}/export_log.json` - Status, errors, statistics

## Usage

```bash
# Export tất cả products
npm run export:filesearch

# Export với filter
npm run export:filesearch -- --brand iPhone
npm run export:filesearch -- --condition new
```
