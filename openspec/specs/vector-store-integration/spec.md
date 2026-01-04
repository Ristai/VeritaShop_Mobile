# vector-store-integration Specification

## Purpose
TBD - created by archiving change add-vector-store-schema. Update Purpose after archive.
## Requirements
### Requirement: FS-001 - Product Document JSON Schema

Hệ thống SHALL tạo một JSON file cho mỗi product, chứa đầy đủ thông tin product, aggregated sentiment từ reviews, và active coupons.

#### Scenario: Generate document cho product có đầy đủ data
- **Given** Product "iPhone 15 Pro Max" tồn tại với:
  - Thông tin cơ bản (name, brand, price, specs, stock)
  - 50 reviews có sentiment analysis
  - 2 coupons đang active
- **When** hệ thống generate document cho product này
- **Then** JSON file SHALL chứa các sections:
  - `product_id`: ObjectId của product
  - `generated_at`: Timestamp tạo document
  - `product_info`: Thông tin product denormalized
  - `sentiment_summary`: Aggregated sentiment theo aspect
  - `featured_reviews`: Top reviews được chọn lọc
  - `active_coupons`: Danh sách coupons đang active
  - `searchable_content`: Text tổng hợp cho semantic search

#### Scenario: Generate document cho product không có reviews
- **Given** Product mới không có reviews
- **When** hệ thống generate document
- **Then** `sentiment_summary.aspects` SHALL là empty object
- **And** `featured_reviews` SHALL là empty array
- **And** document vẫn được tạo với product_info và active_coupons

### Requirement: FS-002 - Aspect Sentiment Aggregation

Hệ thống SHALL tính toán aggregated sentiment score (0-100) cho mỗi aspect dựa trên tất cả reviews của product.

#### Scenario: Calculate sentiment score cho aspect có reviews
- **Given** Product có 30 reviews mention aspect "Camera"
- **And** 25 reviews có sentiment "positive"
- **And** 3 reviews có sentiment "negative"
- **And** 2 reviews có sentiment "neutral"
- **When** hệ thống calculate sentiment score
- **Then** `sentiment_summary.aspects.Camera` SHALL có:
  - `positive_count`: 25
  - `negative_count`: 3
  - `neutral_count`: 2
  - `total`: 30
  - `score`: 83 (positive_count / total * 100, rounded)
  - `summary`: Text tóm tắt từ top positive review

#### Scenario: Handle aspect không có reviews
- **Given** Product không có reviews mention aspect "Packaging"
- **When** hệ thống generate document
- **Then** `sentiment_summary.aspects` SHALL NOT chứa key "Packaging"

### Requirement: FS-003 - Featured Reviews Selection

Hệ thống SHALL chọn featured reviews đại diện để include trong document, ưu tiên reviews có giá trị thông tin cao.

#### Scenario: Select top overall reviews
- **Given** Product có 50 reviews
- **When** hệ thống select featured reviews
- **Then** hệ thống SHALL chọn tối đa 3 reviews "overall_best" dựa trên:
  - Rating = 5 stars
  - Text length >= 50 ký tự
  - Ưu tiên reviews mới hơn (sort by createdAt desc)
  - Ưu tiên verified purchase

#### Scenario: Select top reviews per aspect
- **Given** Product có nhiều reviews cho aspect "Battery"
- **When** hệ thống select featured reviews
- **Then** hệ thống SHALL chọn tối đa 2 reviews có:
  - `type`: "aspect_top"
  - `aspect`: "Battery"
  - Sentiment = "positive"
  - Rating >= 4 stars
  - Text length >= 30 ký tự

#### Scenario: Include constructive negative review
- **Given** Product có negative reviews
- **When** hệ thống select featured reviews
- **Then** hệ thống SHALL include tối đa 1 review có:
  - `type`: "constructive_negative"
  - Rating >= 2 stars (tránh spam/troll)
  - Text length >= 100 ký tự (có giải thích cụ thể)
  - Sentiment = "negative" cho ít nhất một aspect

### Requirement: FS-004 - Active Coupons Inclusion

Hệ thống SHALL include tất cả coupons đang active và áp dụng được cho product.

#### Scenario: Product-specific coupon
- **Given** Coupon "IPHONE10" có `applicableProducts` chứa product ID
- **And** Coupon đang trong thời hạn (startDate <= now <= endDate)
- **And** Coupon có isActive = true
- **When** hệ thống generate document
- **Then** `active_coupons` SHALL chứa coupon với:
  - `code`: "IPHONE10"
  - `description`: Mô tả coupon
  - `discount_type`: "percentage" hoặc "fixed"
  - `discount_value`: Giá trị giảm
  - `max_discount`: Giảm tối đa (null nếu không có)
  - `min_order`: Đơn tối thiểu
  - `end_date`: Ngày hết hạn (ISO format)

#### Scenario: Brand-specific coupon
- **Given** Product có brand = "iPhone"
- **And** Coupon "APPLE2026" có `applicableBrands` chứa "iPhone"
- **And** Coupon đang active
- **When** hệ thống generate document
- **Then** coupon SHALL được include trong `active_coupons`

#### Scenario: Universal coupon (no restrictions)
- **Given** Coupon "NEWYEAR" có `applicableProducts` và `applicableBrands` đều rỗng
- **And** Coupon đang active
- **When** hệ thống generate document cho bất kỳ product
- **Then** coupon SHALL được include trong `active_coupons`

### Requirement: FS-005 - Metadata Attributes for Filtering

Hệ thống SHALL generate metadata attributes file để configure Vector Store filtering.

#### Scenario: Generate attributes schema
- **When** hệ thống export documents
- **Then** hệ thống SHALL tạo `attributes_schema.json` chứa:
  - `product_id`: string
  - `brand`: string
  - `price`: number
  - `price_range`: string (categorized)
  - `stock_status`: string (in_stock/low_stock/out_of_stock)
  - `condition`: string (new/likenew/used)
  - `overall_rating`: number (0-5)
  - `review_count`: number
  - `has_active_coupon`: boolean
  - `Battery_score`, `Camera_score`, etc.: number (0-100)

#### Scenario: Price range categorization
- **Given** Product có price = 28,990,000đ
- **When** hệ thống determine price_range
- **Then** price_range SHALL là "20-30M"
- **And** các ranges khác theo bảng:
  - 0 - 5,000,000 → "0-5M"
  - 5,000,001 - 10,000,000 → "5-10M"
  - 10,000,001 - 15,000,000 → "10-15M"
  - 15,000,001 - 20,000,000 → "15-20M"
  - 20,000,001 - 30,000,000 → "20-30M"
  - 30,000,001 - 50,000,000 → "30-50M"
  - > 50,000,000 → "50M+"

#### Scenario: Stock status derivation
- **Given** Product có stock = 45
- **When** hệ thống determine stock_status
- **Then** stock_status SHALL là "in_stock"
- **And** các rules:
  - stock = 0 → "out_of_stock"
  - stock < 10 → "low_stock"
  - stock >= 10 → "in_stock"

### Requirement: FS-006 - Export Script

Hệ thống SHALL cung cấp script để export tất cả active products thành JSON files.

#### Scenario: Full export
- **Given** Database có 100 active products
- **When** chạy `npm run export:filesearch`
- **Then** hệ thống SHALL:
  - Tạo folder `exports/{date}/products/`
  - Generate một JSON file cho mỗi product: `product_{id}.json`
  - Tạo `exports/{date}/attributes_schema.json`
  - Tạo `exports/{date}/manifest.json` với list files và metadata
  - Tạo `exports/{date}/export_log.json` với status và errors
  - Log progress (N/100 products exported)

#### Scenario: Export với filter
- **Given** User muốn export chỉ products của brand "iPhone"
- **When** chạy `npm run export:filesearch -- --brand=iPhone`
- **Then** hệ thống SHALL chỉ export products có brand = "iPhone"

#### Scenario: Handle export errors
- **Given** Một product có data không hợp lệ
- **When** hệ thống gặp lỗi khi generate document
- **Then** hệ thống SHALL:
  - Log error vào `export_log.json` với product ID và error message
  - Tiếp tục export các products còn lại
  - Tổng kết số products thành công/thất bại

### Requirement: FS-007 - Searchable Content Generation

Hệ thống SHALL generate field `searchable_content` chứa text tổng hợp tối ưu cho semantic search.

#### Scenario: Generate searchable content
- **Given** Product có đầy đủ thông tin
- **When** hệ thống generate searchable_content
- **Then** content SHALL include (theo thứ tự):
  - Tên sản phẩm, hãng, giá (có format VNĐ)
  - Tình trạng, bảo hành, còn hàng
  - Thông số kỹ thuật (chip, RAM, ROM, màn hình, camera, pin)
  - Màu sắc available
  - Đánh giá tổng quan (rating/5 sao, số đánh giá)
  - Đánh giá theo khía cạnh (aspect: score% - summary)
  - Nhận xét nổi bật (quotes từ featured reviews)
  - Khuyến mãi đang áp dụng (mã, mô tả, hạn)

#### Scenario: Bilingual aspect names
- **Given** Aspect "Battery" cần hiển thị
- **When** hệ thống generate searchable_content
- **Then** aspect SHALL được hiển thị với cả tên tiếng Anh và tiếng Việt:
  - "Battery/Pin: 78% tích cực"
  - "Camera: 92% tích cực"
  - "Performance/Hiệu năng: 85% tích cực"
  - "Display/Màn hình: 87% tích cực"
  - "Design/Thiết kế: 76% tích cực"
  - "Price/Giá: 54% tích cực"

