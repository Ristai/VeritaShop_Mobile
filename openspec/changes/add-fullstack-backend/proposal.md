---
noteId: "443f8270ddb411f0a4cff1c6086bb22a"
tags: []

---

# Change: Add Full Stack Backend Integration

## Why
VeritaShop là **website bán điện thoại di động** hiện tại chỉ có frontend Flutter với mock data. Cần xây dựng backend Node.js/Express với MongoDB Atlas để:
- Lưu trữ dữ liệu thực (điện thoại, đơn hàng, users)
- Xác thực người dùng bằng JWT
- Quản lý ảnh sản phẩm qua Cloudinary
- Hỗ trợ Flutter Web + Mobile

## What Changes

### Backend (New)
- **Node.js/Express API Server** với cấu trúc MVC
- **MongoDB Atlas** cho database với Mongoose ODM
- **JWT Authentication** (access token 7d + refresh token 30d)
- **Cloudinary Integration** cho image upload
- **CORS Configuration** cho Flutter Web

### Flutter Frontend (Modified)
- Chuyển từ `MockDataSource` sang `ApiClientImpl` thật
- Cấu hình environment variables cho API endpoints
- Thêm interceptors cho JWT token refresh
- Xử lý errors và loading states

## Domain: Điện Thoại Di Động

### Sản phẩm chính
- iPhone (Apple)
- Samsung Galaxy
- Xiaomi / Redmi
- OPPO / Realme
- Vivo
- Google Pixel
- OnePlus

### Product Attributes đặc thù
- **Thông số kỹ thuật**: RAM, ROM, chip, pin, màn hình
- **Màu sắc**: Các biến thể màu
- **Tình trạng**: Mới / Like New / Đã sử dụng
- **Bảo hành**: Thời gian bảo hành
- **Phụ kiện đi kèm**: Sạc, cáp, tai nghe...

## Impact
- Affected specs: `api-auth`, `api-products`, `api-orders`, `api-cart`, `flutter-integration`
- Affected code:
  - NEW: `backend/` folder (toàn bộ Node.js code)
  - MODIFIED: `lib/data/data_sources/remote/api_client_impl.dart`
  - MODIFIED: `lib/data/repositories/*.dart`
  - MODIFIED: `lib/presentation/view_models/*.dart`
  - MODIFIED: `.env`

## Architecture Overview

```
┌─────────────────┐     HTTPS/REST      ┌─────────────────┐
│  Flutter Web/   │ ◄─────────────────► │   Node.js       │
│  Mobile App     │      JWT Auth       │   Express API   │
└─────────────────┘                     └────────┬────────┘
                                                 │
                                    ┌────────────┼────────────┐
                                    ▼            ▼            ▼
                              ┌──────────┐ ┌──────────┐ ┌──────────┐
                              │ MongoDB  │ │Cloudinary│ │  Email   │
                              │  Atlas   │ │  (CDN)   │ │ Service  │
                              └──────────┘ └──────────┘ └──────────┘
```

## API Endpoints Summary

| Module | Endpoints |
|--------|-----------|
| Auth | `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/refresh`, `POST /api/auth/logout` |
| Products | `GET /api/products`, `GET /api/products/:id`, `GET /api/products/category/:category`, `GET /api/products/search` |
| Cart | `GET /api/cart`, `POST /api/cart`, `PUT /api/cart/:id`, `DELETE /api/cart/:id` |
| Orders | `GET /api/orders`, `POST /api/orders`, `GET /api/orders/:id`, `PUT /api/orders/:id/cancel` |
| Reviews | `GET /api/reviews/product/:productId`, `POST /api/reviews`, `PUT /api/reviews/:id`, `DELETE /api/reviews/:id` |
| Users | `GET /api/users/profile`, `PUT /api/users/profile`, `POST /api/users/avatar` |
| Upload | `POST /api/upload/image` |

## Success Criteria
1. Backend chạy được với `npm run dev`
2. Flutter Web kết nối được với backend qua REST API
3. User có thể đăng ký, đăng nhập, và duy trì session
4. CRUD operations cho products, cart, orders hoạt động
5. Image upload lên Cloudinary thành công
