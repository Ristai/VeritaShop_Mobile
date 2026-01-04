# OpenAI File Search Export

Công cụ export dữ liệu sản phẩm từ MongoDB sang JSON files để upload lên OpenAI Vector Store.

## Cách sử dụng

### Export tất cả sản phẩm

```bash
cd backend
npm run export:filesearch
```

### Export với bộ lọc

```bash
# Export chỉ sản phẩm iPhone
npm run export:filesearch -- --brand iPhone

# Export sản phẩm mới
npm run export:filesearch -- --condition new

# Export vào thư mục tùy chỉnh
npm run export:filesearch -- --output ./my-exports

# Kết hợp nhiều bộ lọc
npm run export:filesearch -- --brand Samsung --condition new
```

### Tham số CLI

| Tham số | Mô tả | Giá trị mặc định |
|---------|-------|------------------|
| `--brand` | Lọc theo hãng (iPhone, Samsung, Xiaomi, OPPO, Vivo) | Tất cả |
| `--condition` | Lọc theo tình trạng (new, likenew, used) | Tất cả |
| `--date` | Tên thư mục ngày export (YYYY-MM-DD) | Ngày hiện tại |
| `--output` | Thư mục xuất | `./exports` |

## Cấu trúc Output

```
exports/
├── 2026-01-05/
│   ├── products/
│   │   ├── product_678abc123def456.json
│   │   ├── product_789def456ghi789.json
│   │   └── ...
│   ├── attributes_schema.json   # Schema cho Vector Store attributes
│   ├── manifest.json            # Danh sách files + metadata
│   └── export_log.json          # Log export (status, errors)
```

### Cấu trúc Document (product_*.json)

```json
{
  "product_id": "678abc123def456",
  "generated_at": "2026-01-05T10:00:00Z",
  "product_info": {
    "name": "iPhone 15 Pro Max 256GB",
    "brand": "iPhone",
    "price": 28990000,
    "original_price": 33990000,
    "discount_percent": 15,
    "condition": "new",
    "warranty": "12 tháng",
    "stock": 45,
    "stock_status": "in_stock",
    "rating": 4.6,
    "review_count": 127,
    "specs": { ... },
    "colors": ["Titan Đen", "Titan Trắng"],
    "images": ["url1", "url2"]
  },
  "sentiment_summary": {
    "overall_sentiment": "positive",
    "total_reviews": 127,
    "aspects": {
      "Battery": { "positive_count": 32, "negative_count": 5, "score": 78, "summary": "..." },
      "Camera": { "positive_count": 41, "negative_count": 2, "score": 92, "summary": "..." }
    }
  },
  "featured_reviews": [
    { "type": "overall_best", "user_name": "...", "rating": 5, "text": "..." },
    { "type": "aspect_top", "aspect": "Camera", "rating": 5, "text": "..." }
  ],
  "active_coupons": [
    { "code": "IPHONE10", "discount_type": "percentage", "discount_value": 10, ... }
  ],
  "searchable_content": "... (text tối ưu cho semantic search)"
}
```

### Attributes Schema

Dùng để cấu hình filtering trong OpenAI Vector Store:

```json
{
  "attributes": [
    { "name": "product_id", "type": "string" },
    { "name": "brand", "type": "string" },
    { "name": "price", "type": "number" },
    { "name": "price_range", "type": "string" },
    { "name": "stock_status", "type": "string" },
    { "name": "condition", "type": "string" },
    { "name": "overall_rating", "type": "number" },
    { "name": "review_count", "type": "number" },
    { "name": "has_active_coupon", "type": "boolean" },
    { "name": "Battery_score", "type": "number" },
    { "name": "Camera_score", "type": "number" },
    { "name": "Performance_score", "type": "number" },
    { "name": "Display_score", "type": "number" },
    { "name": "Design_score", "type": "number" },
    { "name": "Price_score", "type": "number" }
  ]
}
```

## Upload lên OpenAI Vector Store

### Bước 1: Tạo Vector Store

1. Đăng nhập [OpenAI Platform](https://platform.openai.com)
2. Vào Storage → Vector Stores
3. Tạo Vector Store mới với tên phù hợp (VD: "VeritaShop Products")

### Bước 2: Upload Files

1. Chọn Vector Store vừa tạo
2. Click "Upload files"
3. Chọn tất cả files trong thư mục `exports/{date}/products/`
4. Đợi processing hoàn tất

### Bước 3: Cấu hình Attributes

Khi upload từng file, set attributes theo `manifest.json`:

```json
{
  "product_id": "678abc123def456",
  "brand": "iPhone",
  "price": 28990000,
  "price_range": "20-30M",
  "stock_status": "in_stock",
  "condition": "new",
  "overall_rating": 4.6,
  "review_count": 127,
  "has_active_coupon": true,
  "Battery_score": 78,
  "Camera_score": 92,
  "Performance_score": 85,
  "Display_score": 88,
  "Design_score": 75,
  "Price_score": 55
}
```

### Bước 4: Sử dụng với File Search

Trong Assistants API:

```json
{
  "tools": [{ "type": "file_search" }],
  "tool_resources": {
    "file_search": {
      "vector_store_ids": ["vs_xxx"]
    }
  }
}
```

Với filtering:

```json
{
  "filters": {
    "type": "and",
    "filters": [
      { "type": "eq", "key": "brand", "value": "iPhone" },
      { "type": "gte", "key": "Battery_score", "value": 70 }
    ]
  }
}
```

## Price Range Categories

| Giá (VNĐ) | Label |
|-----------|-------|
| 0 - 5,000,000 | "0-5M" |
| 5,000,001 - 10,000,000 | "5-10M" |
| 10,000,001 - 15,000,000 | "10-15M" |
| 15,000,001 - 20,000,000 | "15-20M" |
| 20,000,001 - 30,000,000 | "20-30M" |
| 30,000,001 - 50,000,000 | "30-50M" |
| > 50,000,000 | "50M+" |

## Troubleshooting

### Lỗi kết nối MongoDB

Đảm bảo biến môi trường `MONGODB_URI` được set trong file `.env`:

```
MONGODB_URI=mongodb://localhost:27017/veritashop
```

### Export chậm

- Chạy với filter để giảm số lượng sản phẩm
- Kiểm tra số lượng reviews (nhiều reviews = chậm hơn)

### File size lớn

- Giới hạn featured_reviews trong `reviewSelector.js`
- Giảm độ dài `searchable_content`
