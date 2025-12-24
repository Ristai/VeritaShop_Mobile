---
noteId: "5b180d00ddb411f0a4cff1c6086bb22a"
tags: []

---

# Tasks: Full Stack Backend Integration

## Phase 1: Backend Project Setup
- [x] 1.1 Khởi tạo Node.js project với `npm init`
- [x] 1.2 Cài đặt dependencies (express, mongoose, bcrypt, jsonwebtoken, cors, dotenv, cloudinary, multer, joi)
- [x] 1.3 Tạo cấu trúc thư mục backend (src/config, controllers, middleware, models, routes, utils)
- [x] 1.4 Cấu hình MongoDB Atlas connection
- [x] 1.5 Cấu hình CORS cho Flutter Web
- [x] 1.6 Setup Cloudinary config
- [x] 1.7 Tạo `.env.example` với các environment variables cần thiết

## Phase 2: Authentication Module
- [x] 2.1 Tạo User model (name, email, password, avatar, addresses, refreshToken)
- [x] 2.2 Implement auth middleware (JWT verification)
- [x] 2.3 Implement `POST /api/auth/register`
- [x] 2.4 Implement `POST /api/auth/login`
- [x] 2.5 Implement `POST /api/auth/refresh` (refresh token)
- [x] 2.6 Implement `POST /api/auth/logout`
- [x] 2.7 Implement `GET /api/users/profile`
- [x] 2.8 Implement `PUT /api/users/profile`
- [x] 2.9 Test auth flow với Postman/Thunder Client

## Phase 3: Phone Products Module
- [x] 3.1 Tạo Phone Product model với các thuộc tính:
  - Cơ bản: name, brand, description, price, originalPrice, images[], stock
  - Specs: ram, rom, chip, battery, screen, camera
  - Khác: colors[], condition (new/likenew/used), warranty, rating, reviewCount, isFeatured, tags[]
- [x] 3.2 Implement `GET /api/products` (với pagination, filter by brand/price/specs/condition, sort)
- [x] 3.3 Implement `GET /api/products/:id`
- [x] 3.4 Implement `GET /api/products/search?q=keyword`
- [x] 3.5 Implement `GET /api/products/brand/:brand` (iPhone, Samsung, Xiaomi, OPPO, Vivo, Other)
- [x] 3.6 Implement `GET /api/products/brands` (danh sách brands)
- [x] 3.7 Implement `GET /api/products/featured`
- [x] 3.8 Tạo seed data script với điện thoại mẫu (iPhone 15, Samsung S24, Xiaomi 14, etc.)
- [x] 3.9 Test phone products API

## Phase 4: Cart Module
- [x] 4.1 Tạo Cart model (userId, items[{productId, color, quantity, price}])
- [x] 4.2 Implement `GET /api/cart` (lấy cart của user hiện tại)
- [x] 4.3 Implement `POST /api/cart` (thêm điện thoại vào cart với màu sắc)
- [x] 4.4 Implement `PUT /api/cart/:itemId` (cập nhật quantity)
- [x] 4.5 Implement `DELETE /api/cart/:itemId` (xóa item)
- [x] 4.6 Implement `DELETE /api/cart` (clear cart)
- [x] 4.7 Test cart API

## Phase 5: Orders Module
- [x] 5.1 Tạo Order model (userId, items, shippingAddress, paymentMethod, status, subtotal, shippingFee, tax, total)
- [x] 5.2 Implement `POST /api/orders` (tạo đơn hàng từ cart)
- [x] 5.3 Implement `GET /api/orders` (lịch sử đơn hàng)
- [x] 5.4 Implement `GET /api/orders/:id` (chi tiết đơn hàng)
- [x] 5.5 Implement `PUT /api/orders/:id/cancel` (hủy đơn hàng)
- [x] 5.6 Test orders API

## Phase 6: Reviews Module
- [x] 6.1 Tạo Review model (userId, productId, rating, text, createdAt)
- [x] 6.2 Implement `GET /api/reviews/product/:productId`
- [x] 6.3 Implement `POST /api/reviews` (đánh giá điện thoại)
- [x] 6.4 Implement `PUT /api/reviews/:id`
- [x] 6.5 Implement `DELETE /api/reviews/:id`
- [x] 6.6 Update Phone rating khi có review mới
- [x] 6.7 Test reviews API

## Phase 7: Image Upload
- [x] 7.1 Cấu hình Multer cho file upload
- [x] 7.2 Implement `POST /api/upload/image` (upload lên Cloudinary)
- [x] 7.3 Implement `POST /api/users/avatar` (upload avatar)
- [x] 7.4 Test image upload

## Phase 8: Flutter Integration - API Client
- [x] 8.1 Cập nhật `.env` với API_BASE_URL thật
- [x] 8.2 Tạo AuthInterceptor (tự động thêm Bearer token)
- [x] 8.3 Tạo RefreshInterceptor (tự động refresh token khi 401)
- [x] 8.4 Tạo ErrorInterceptor (xử lý lỗi thống nhất)
- [x] 8.5 Cập nhật ApiClientImpl với interceptors

## Phase 9: Flutter Integration - Repositories
- [x] 9.1 Cập nhật AuthViewModel để dùng API thật
- [x] 9.2 Cập nhật ProductRepository → ApiClient
- [x] 9.3 Cập nhật CartRepository → ApiClient
- [x] 9.4 Tạo OrderRepository với API calls
- [x] 9.5 Cập nhật ReviewRepository → ApiClient
- [x] 9.6 Cập nhật WishlistViewModel (local storage hoặc API)

## Phase 10: Testing & Polish
- [x] 10.1 Test đăng ký/đăng nhập end-to-end
- [x] 10.2 Test phone listing, filter by brand/specs, và search
- [x] 10.3 Test cart operations (thêm điện thoại với màu sắc)
- [x] 10.4 Test checkout flow
- [x] 10.5 Test trên Flutter Web (CORS)
- [ ] 10.6 Test trên mobile (Android/iOS)
- [x] 10.7 Fix bugs và optimize performance
- [ ] 10.8 Cập nhật README với hướng dẫn setup

## Dependencies

```
Phase 1 ──► Phase 2 ──► Phase 8 (Auth cần trước)
              │
              ▼
         Phase 3 ──► Phase 6 (Products trước Reviews)
              │
              ▼
         Phase 4 ──► Phase 5 (Cart trước Orders)
              │
              ▼
         Phase 7 (Upload có thể song song)
              │
              ▼
         Phase 9 ──► Phase 10
```

## Estimated Time
- Phase 1-2: 1-2 ngày
- Phase 3-6: 2-3 ngày
- Phase 7: 0.5 ngày
- Phase 8-9: 1-2 ngày
- Phase 10: 1 ngày

**Total: ~7-10 ngày**
