# Tasks: Document Generation for OpenAI File Search

## 1. Document Generator Service

- [x] 1.1 Create `backend/src/services/fileSearchExport/` directory structure
  - `documentGenerator.js` - Main generator logic
  - `sentimentAggregator.js` - Aggregate reviews by aspect
  - `reviewSelector.js` - Select featured reviews
  - `couponMatcher.js` - Match applicable coupons
  - `contentFormatter.js` - Generate searchable_content text

- [x] 1.2 Implement sentiment aggregation
  - Query reviews by product ID
  - Group by aspect, count positive/negative/neutral
  - Calculate score = (positive_count / total) * 100
  - Generate summary từ top positive review text

- [x] 1.3 Implement featured reviews selection
  - Select top 3 overall reviews (5★, >= 50 chars, recent)
  - Select top 2 per aspect (positive sentiment, >= 4★)
  - Select 1 constructive negative (>= 2★, >= 100 chars)
  - Limit total featured reviews to prevent file bloat

- [x] 1.4 Implement coupon matching
  - Query active coupons (isActive, within date range)
  - Match by applicableProducts (contains product ID)
  - Match by applicableBrands (contains product brand)
  - Include universal coupons (no restrictions)

## 2. Helper Functions

- [x] 2.1 Implement price range categorization
  - `getPriceRange(price)` returns "0-5M", "5-10M", etc.
  - Follow spec ranges exactly

- [x] 2.2 Implement stock status derivation
  - `getStockStatus(stock)` returns "in_stock", "low_stock", "out_of_stock"
  - Rules: 0 → out_of_stock, < 10 → low_stock, >= 10 → in_stock

- [x] 2.3 Implement searchable content generator
  - Format product info, specs, sentiment, reviews, coupons
  - Use bilingual aspect names (Battery/Pin, Display/Màn hình)
  - Format prices với VNĐ

## 3. Export Script

- [x] 3.1 Create `backend/src/scripts/exportFileSearch.js`
  - Accept CLI arguments: --brand, --condition, --date
  - Create output directory `exports/{date}/products/`
  - Progress logging (N/total exported)

- [x] 3.2 Implement document export loop
  - Query active products (isActive = true)
  - Apply filters if provided
  - Generate JSON document cho mỗi product
  - Write to `product_{id}.json`

- [x] 3.3 Generate metadata files
  - `attributes_schema.json` - Schema for Vector Store attributes
  - `manifest.json` - List of files với metadata for bulk upload
  - `export_log.json` - Status, errors, statistics

- [x] 3.4 Add npm script
  - Add `"export:filesearch": "node src/scripts/exportFileSearch.js"` to package.json

## 4. Error Handling

- [x] 4.1 Handle missing data gracefully
  - Products without reviews → empty sentiment_summary.aspects
  - Products without applicable coupons → empty active_coupons
  - Missing optional fields → omit from document

- [x] 4.2 Export error recovery
  - Log errors với product ID và error message
  - Continue with remaining products
  - Summary report (success/failed counts)

## 5. Testing

- [x] 5.1 Test sentiment aggregation accuracy
  - Verify score calculation matches manual calculation
  - Test with products có 0, 1, 10, 100 reviews

- [x] 5.2 Test featured review selection
  - Verify selection criteria applied correctly
  - Test edge cases (no 5★ reviews, no negative reviews)

- [x] 5.3 Test coupon matching
  - Product-specific coupons
  - Brand-specific coupons
  - Universal coupons
  - Expired coupons (should NOT be included)

- [x] 5.4 Test full export
  - Run export với real data
  - Verify JSON structure matches spec
  - Verify file naming convention

## 6. Documentation

- [x] 6.1 Add README for export usage
  - How to run export script
  - CLI arguments documentation
  - Output file structure explanation

- [x] 6.2 Add upload instructions
  - How to create Vector Store on OpenAI
  - How to upload files
  - How to set attributes per file

## Dependencies

- Task 1.x phải hoàn thành trước Task 3.x
- Task 2.x có thể làm parallel với Task 1.x
- Task 5.x sau khi hoàn thành Task 1-4

## Parallelizable Work

- Task 1.2, 1.3, 1.4 có thể làm parallel
- Task 2.1, 2.2, 2.3 có thể làm parallel
- Task 5.1, 5.2, 5.3 có thể làm parallel
