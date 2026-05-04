# Design: Document Generation for OpenAI File Search

## Context

VeritaShop cần xây dựng chatbot thông minh có khả năng trả lời các câu hỏi phức tạp về sản phẩm như:
- "Điện thoại nào có pin tốt nhất trong tầm giá 15 triệu?"
- "Sản phẩm Samsung nào đang được đánh giá cao về camera?"
- "Có khuyến mãi nào cho iPhone không?"

**Approach**: Sử dụng OpenAI File Search (Vector Store) - upload documents lên OpenAI để họ tự xử lý chunking và indexing. Chúng ta chỉ cần:
1. Tạo document files có structure tối ưu
2. Set metadata attributes cho filtering
3. Upload lên Vector Store

**Current State:**
- Product, Review, Coupon lưu trong 3 collections riêng biệt
- ABSA sentiment analysis đã được tích hợp với 11 aspects
- Chưa có cách export data cho File Search

**Constraints:**
- OpenAI File Search hỗ trợ JSON, Markdown, PDF, DOCX, etc.
- Metadata attributes support: string, number, boolean
- File size limit: 512MB per file, 100GB per vector store

## Goals / Non-Goals

### Goals
- Tạo JSON files chứa đầy đủ thông tin product + reviews + coupons
- Thiết kế metadata attributes cho filtering queries phổ biến
- Script tự động export từ MongoDB
- Document format giúp LLM dễ tổng hợp câu trả lời
- **Data freshness notice** để LLM thông báo cho user biết data không phải real-time

### Non-Goals
- Real-time sync (manual re-export khi cần)
- Programmatic upload (upload thủ công qua OpenAI website)
- Tự tạo embeddings (OpenAI File Search xử lý)

## Decisions

### Decision 1: JSON File Format với Structured Sections

**What:** Mỗi product là một JSON file với content được chia thành sections rõ ràng

**Why:**
- JSON dễ generate từ MongoDB
- Structured sections giúp LLM locate thông tin
- OpenAI File Search parse JSON tốt

**File naming convention:**
```
product_{product_id}.json
```

### Decision 2: Metadata Attributes cho Filtering

**What:** Sử dụng Vector Store attributes để filter trước khi semantic search

**Why:**
- Giảm số documents cần search
- Support queries như "iPhone có pin tốt" (filter brand + aspect score)
- OpenAI native filtering performant hơn post-filtering

**Attributes schema (set khi upload file):**
```json
{
  "product_id": "string",
  "brand": "string",
  "price": "number",
  "price_range": "string",
  "stock_status": "string",
  "condition": "string",
  "overall_rating": "number",
  "review_count": "number",
  "has_active_coupon": "boolean",
  "Battery_score": "number",
  "Camera_score": "number",
  "Performance_score": "number",
  "Display_score": "number",
  "Design_score": "number",
  "Price_score": "number"
}
```

### Decision 3: Pre-aggregated Aspect Sentiment Scores

**What:** Tính toán sẵn positive percentage cho mỗi aspect (0-100) từ reviews thật trong database

**Why:**
- Cho phép filter: `Battery_score >= 70`
- Không cần LLM tự tổng hợp từ raw reviews
- Đơn giản hóa queries

### Decision 4: All Reviews + Featured Reviews

**What:** Export tất cả reviews từ DB (max 50) + subset featured reviews (max 15)

**Why:**
- `all_reviews` - Đầy đủ thông tin cho LLM tham khảo chi tiết
- `featured_reviews` - Subset tốt nhất cho quick reference
- Cả hai đều lấy từ database thật, không phải mock data

**Selection criteria cho featured_reviews:**
- Top 3 overall reviews (highest rating)
- Top 2 reviews per aspect (any sentiment mentioned)
- Up to 2 constructive negative reviews (rating <= 3)
- Fill remaining với any unused reviews

### Decision 5: Data Freshness Notice

**What:** Thêm `data_updated_at` và `data_notice` để LLM thông báo cho user biết data không phải real-time

**Why:**
- User cần biết thông tin có thể đã thay đổi
- LLM có thể trả lời chính xác "Thông tin này cập nhật đến ngày X"
- Tránh hiểu nhầm về tính real-time của data

**Fields:**
```json
{
  "data_updated_at": "10:30 ngày 05/01/2026",
  "data_notice": "Thông tin sản phẩm được cập nhật đến 10:30 ngày 05/01/2026. Dữ liệu có thể đã thay đổi sau thời điểm này."
}
```

## Document Schema

### File Structure

```json
{
  "product_id": "ObjectId string",
  "generated_at": "ISO timestamp",
  "data_updated_at": "10:30 ngày 05/01/2026",
  "data_notice": "Thông tin sản phẩm được cập nhật đến 10:30 ngày 05/01/2026. Dữ liệu có thể đã thay đổi sau thời điểm này.",

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
    "specs": {
      "ram": "8GB",
      "rom": "256GB",
      "chip": "A17 Pro",
      "battery": "4422mAh",
      "screen": "6.7 inch OLED",
      "camera": "48MP + 12MP + 12MP"
    },
    "colors": ["Titan Đen", "Titan Trắng", "Titan Xanh"],
    "images": ["url1", "url2"]
  },

  "sentiment_summary": {
    "overall_sentiment": "positive",
    "total_reviews": 127,
    "aspects": {
      "Battery": {
        "positive_count": 32,
        "negative_count": 5,
        "neutral_count": 4,
        "total": 41,
        "score": 78,
        "summary": "Pin dùng cả ngày, sạc nhanh"
      },
      "Camera": {
        "positive_count": 41,
        "negative_count": 2,
        "neutral_count": 2,
        "total": 45,
        "score": 92,
        "summary": "Camera chụp đêm đẹp, zoom quang học tốt"
      }
    }
  },

  "all_reviews": [
    {
      "review_id": "abc123",
      "user_name": "Nguyễn Văn A",
      "rating": 5,
      "title": "Sản phẩm tuyệt vời",
      "text": "Điện thoại rất đáng mua...",
      "sentiment": "positive",
      "aspects_mentioned": ["Camera", "Battery"],
      "sentiment_analysis": [
        {"aspect": "Camera", "sentiment": "positive", "confidence": 0.95},
        {"aspect": "Battery", "sentiment": "positive", "confidence": 0.88}
      ],
      "created_at": "2026-01-03",
      "is_verified_purchase": true,
      "likes": 15
    }
  ],

  "featured_reviews": [
    {
      "type": "overall_best",
      "user_name": "Nguyễn Văn A",
      "rating": 5,
      "sentiment": "positive",
      "text": "Điện thoại rất đáng mua...",
      "aspects_mentioned": ["Camera", "Battery", "Performance"],
      "created_at": "2026-01-03",
      "is_verified_purchase": true
    },
    {
      "type": "aspect_top",
      "aspect": "Camera",
      "user_name": "Trần Thị B",
      "rating": 5,
      "sentiment": "positive",
      "text": "Camera chụp đêm quá đỉnh...",
      "aspects_mentioned": ["Camera"],
      "created_at": "2026-01-02",
      "is_verified_purchase": true
    }
  ],

  "active_coupons": [
    {
      "code": "IPHONE10",
      "description": "Giảm 10% cho iPhone",
      "discount_type": "percentage",
      "discount_value": 10,
      "max_discount": 2000000,
      "min_order": 0,
      "end_date": "2026-01-31"
    }
  ],

  "searchable_content": "iPhone 15 Pro Max 256GB - Hãng iPhone - Giá 28,990,000đ..."
}
```

### Metadata Attributes (for Vector Store filtering)

Khi upload file lên OpenAI Vector Store, set các attributes sau:

```json
{
  "product_id": "product_123",
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

## LLM Query Examples

### Query 1: "Điện thoại nào có pin tốt nhất?"

**File Search với filter:**
```json
{
  "filters": {
    "type": "gte",
    "key": "Battery_score",
    "value": 70
  }
}
```

**LLM Response từ document:**
```
Dựa trên đánh giá của khách hàng (cập nhật đến 10:30 ngày 05/01/2026), đây là các điện thoại có pin tốt nhất:

1. **iPhone 15 Pro Max 256GB** - 28,990,000đ
   - Đánh giá pin: 78% tích cực (41 đánh giá)
   - "Pin dùng được từ sáng đến tối, sạc nhanh 20W" - Lê Minh Châu ★★★★★
   - Khuyến mãi: Giảm 10% với mã IPHONE10

Lưu ý: Thông tin có thể đã thay đổi sau thời điểm cập nhật.
```

### Query 2: "Sản phẩm iPhone đang có khuyến mãi?"

**File Search với filter:**
```json
{
  "filters": {
    "type": "and",
    "filters": [
      {"type": "eq", "key": "brand", "value": "iPhone"},
      {"type": "eq", "key": "has_active_coupon", "value": true}
    ]
  }
}
```

### Query 3: "So sánh camera iPhone và Samsung"

**File Search với filter:**
```json
{
  "filters": {
    "type": "and",
    "filters": [
      {"type": "in", "key": "brand", "value": ["iPhone", "Samsung"]},
      {"type": "gte", "key": "Camera_score", "value": 60}
    ]
  }
}
```

## Export Script Output

Script sẽ tạo folder structure:

```
exports/
├── 2026-01-05/
│   ├── products/
│   │   ├── product_678abc123def456.json
│   │   ├── product_789def456ghi789.json
│   │   └── ...
│   ├── attributes_schema.json   # Schema cho Vector Store attributes
│   ├── manifest.json            # List files + metadata for bulk upload
│   └── export_log.json          # Export status và errors
```

**attributes_schema.json:**
```json
{
  "attributes": [
    {"name": "product_id", "type": "string"},
    {"name": "brand", "type": "string"},
    {"name": "price", "type": "number"},
    {"name": "price_range", "type": "string"},
    {"name": "stock_status", "type": "string"},
    {"name": "condition", "type": "string"},
    {"name": "overall_rating", "type": "number"},
    {"name": "review_count", "type": "number"},
    {"name": "has_active_coupon", "type": "boolean"},
    {"name": "Battery_score", "type": "number"},
    {"name": "Camera_score", "type": "number"},
    {"name": "Performance_score", "type": "number"},
    {"name": "Display_score", "type": "number"},
    {"name": "Design_score", "type": "number"},
    {"name": "Price_score", "type": "number"}
  ]
}
```

## Price Range Categorization

| Price (VNĐ) | Range Label |
|-------------|-------------|
| 0 - 5,000,000 | "0-5M" |
| 5,000,001 - 10,000,000 | "5-10M" |
| 10,000,001 - 15,000,000 | "10-15M" |
| 15,000,001 - 20,000,000 | "15-20M" |
| 20,000,001 - 30,000,000 | "20-30M" |
| 30,000,001 - 50,000,000 | "30-50M" |
| > 50,000,000 | "50M+" |

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Data staleness | Re-export khi data thay đổi quan trọng + data_notice field |
| Large export size | Chỉ export active products, limit reviews to 50 |
| Missing reviews | Graceful handling cho products không có reviews |
| Coupon expiry | Include end_date, filter expired khi export |

## Open Questions

1. **Export frequency** - Daily? Weekly? On-demand?
   - Recommendation: On-demand với option scheduled export

2. **Review count threshold** - Minimum reviews để include sentiment?
   - Recommendation: Include tất cả, mark "insufficient_data" nếu < 5 reviews

3. **Historical data** - Có cần export products đã ngừng bán?
   - Recommendation: Không, chỉ export isActive = true
