---
noteId: "86983863ddb411f0a4cff1c6086bb22a"
tags: []

---

## ADDED Requirements

### Requirement: Phone Product Model
The system SHALL store phone products with mobile-specific attributes.

#### Scenario: Phone product structure
- **GIVEN** a phone product in the database
- **THEN** it contains: name, brand, description, price, originalPrice, images[], category (brand), stock, colors[], specs (ram, rom, chip, battery, screen, camera), condition (new/likenew/used), warranty, rating, reviewCount, isFeatured, tags[], createdAt

#### Scenario: Phone specifications
- **WHEN** creating a phone product
- **THEN** specs object includes: ram (e.g., "8GB"), rom (e.g., "256GB"), chip (e.g., "A17 Pro"), battery (e.g., "4422mAh"), screen (e.g., "6.7 inch OLED"), camera (e.g., "48MP + 12MP + 12MP")

---

### Requirement: Get All Phones
The system SHALL return paginated list of phones with filtering and sorting options.

#### Scenario: Get phones with default pagination
- **WHEN** client requests `GET /api/products`
- **THEN** system returns first 20 phones sorted by createdAt descending
- **AND** includes pagination metadata (page, limit, total, totalPages)

#### Scenario: Filter by brand
- **WHEN** client requests `GET /api/products?brand=iPhone` or `brand=Samsung`
- **THEN** system returns only phones of that brand

#### Scenario: Filter by price range
- **WHEN** client requests `GET /api/products?minPrice=10000000&maxPrice=30000000`
- **THEN** system returns phones within price range

#### Scenario: Filter by specs
- **WHEN** client requests `GET /api/products?ram=8GB&rom=256GB`
- **THEN** system returns phones matching specifications

#### Scenario: Filter by condition
- **WHEN** client requests `GET /api/products?condition=new` or `condition=likenew`
- **THEN** system returns phones with matching condition

#### Scenario: Sort phones
- **WHEN** client requests `GET /api/products?sort=price_asc` or `sort=price_desc` or `sort=rating` or `sort=newest`
- **THEN** system returns phones sorted accordingly

---

### Requirement: Get Phone by ID
The system SHALL return detailed phone information by ID.

#### Scenario: Phone exists
- **WHEN** client requests `GET /api/products/:id` with valid phone ID
- **THEN** system returns full phone details including all specs, images, colors, warranty info

#### Scenario: Phone not found
- **WHEN** client requests phone with non-existent ID
- **THEN** system returns 404 error with message "Không tìm thấy sản phẩm"

---

### Requirement: Search Phones
The system SHALL allow searching phones by keyword.

#### Scenario: Search with results
- **WHEN** client requests `GET /api/products/search?q=iPhone 15`
- **THEN** system returns phones where name, brand, description, or specs contain keyword
- **AND** results are case-insensitive

#### Scenario: Search with no results
- **WHEN** client searches for non-matching keyword
- **THEN** system returns empty array with pagination showing total: 0

---

### Requirement: Get Featured Phones
The system SHALL return featured/promoted phones.

#### Scenario: Get featured phones
- **WHEN** client requests `GET /api/products/featured`
- **THEN** system returns phones where isFeatured is true
- **AND** limited to 10 phones by default

---

### Requirement: Get Phones by Brand
The system SHALL return phones filtered by brand (category).

#### Scenario: Valid brand
- **WHEN** client requests `GET /api/products/brand/iPhone` or `/brand/Samsung`
- **THEN** system returns all phones of that brand with pagination

#### Scenario: Get all brands
- **WHEN** client requests `GET /api/products/brands`
- **THEN** system returns list of available brands: ["iPhone", "Samsung", "Xiaomi", "OPPO", "Vivo", "Other"]
