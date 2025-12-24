---
noteId: "443f8271ddb411f0a4cff1c6086bb22a"
tags: []

---

# Design: Full Stack Backend Architecture

## Context
VeritaShop là **website chuyên bán điện thoại di động** cần backend để:
- Lưu trữ dữ liệu persistent (điện thoại, đơn hàng, users)
- Xác thực người dùng
- Xử lý đơn hàng
- Quản lý media (ảnh điện thoại)

**Domain:** Điện thoại di động (iPhone, Samsung, Xiaomi, OPPO, Vivo, etc.)

**Constraints:**
- Flutter Web cần CORS support
- Vietnamese market (VNĐ currency)
- Mobile-first nhưng hỗ trợ web

## Goals / Non-Goals

### Goals
- RESTful API với Node.js/Express
- MongoDB Atlas cho scalability
- JWT authentication với refresh token
- Cloudinary cho CDN và image optimization
- Clean architecture dễ maintain

### Non-Goals
- GraphQL (quá phức tạp cho MVP)
- Real-time features (WebSocket) - phase 2
- Payment gateway integration - phase 2
- Admin dashboard - phase 2

## Technology Decisions

### Backend Stack
| Component | Choice | Rationale |
|-----------|--------|-----------|
| Runtime | Node.js 18+ | Phổ biến, ecosystem lớn, async I/O tốt |
| Framework | Express.js | Lightweight, flexible, nhiều middleware |
| Database | MongoDB Atlas | NoSQL phù hợp e-commerce, free tier, scalable |
| ODM | Mongoose | Schema validation, middleware, populate |
| Auth | JWT + bcrypt | Stateless, phù hợp mobile/web |
| Image | Cloudinary | CDN, auto-optimization, generous free tier |
| Validation | Joi/express-validator | Input validation |
| Environment | dotenv | Config management |

### Environment Configuration (Provided)

```env
# MongoDB Atlas
MONGODB_URI=mongodb+srv://veritashops_admin:0Qz9lUxgGy2PfGa3@veritashop.1jwpff1.mongodb.net/veritashop?retryWrites=true&w=majority

# JWT
JWT_SECRET=f3b1c9e2a7d4f8b5c6e1a2d3f4b5c6e7d8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b33
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# Cloudinary
CLOUDINARY_CLOUD_NAME=drpxqclmg
CLOUDINARY_API_KEY=937591186796482
CLOUDINARY_API_SECRET=p9TVAyi_dnCZOTw4J5CvWjFxpKM

# Server
PORT=3000
NODE_ENV=development

# Frontend URLs (for CORS)
FRONTEND_URL=http://localhost:3000
```

**Note:** Các credentials trên đã được cung cấp sẵn, chỉ cần tạo file `.env` trong thư mục `backend/`.

### Database Schema Design

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────┐
│      User       │     │     Product     │     │   Review    │
├─────────────────┤     │   (Phone)       │     ├─────────────┤
│ _id             │     ├─────────────────┤     │ _id         │
│ name            │     │ _id             │     │ userId ────────┐
│ email           │     │ name            │     │ productId ─────┼──┐
│ password        │     │ brand           │     │ rating      │  │  │
│ avatar          │     │ description     │     │ text        │  │  │
│ phone           │     │ price           │     │ createdAt   │  │  │
│ addresses[]     │     │ originalPrice   │     └─────────────┘  │  │
│ createdAt       │     │ images[]        │                      │  │
└─────────────────┘     │ category        │◄─────────────────────┘  │
       │                │ stock           │                         │
       │                │ colors[]        │                         │
       │                │ specs {         │                         │
       │                │   ram, rom,     │                         │
       │                │   chip, battery,│                         │
       │                │   screen, camera│                         │
       │                │ }               │                         │
       │                │ condition       │  (new/likenew/used)     │
       │                │ warranty        │                         │
       │                │ rating          │                         │
       │                │ reviewCount     │                         │
       │                │ isFeatured      │                         │
       │                │ tags[]          │                         │
       │                └─────────────────┘                         │
       │                        ▲                                   │
       ▼                        │                                   │
┌─────────────┐     ┌───────────┴───┐     ┌─────────────┐          │
│    Cart     │     │   CartItem    │     │   Order     │          │
├─────────────┤     ├───────────────┤     ├─────────────┤          │
│ _id         │     │ productId ────┘     │ _id         │          │
│ userId ─────┼──┐  │ color         │     │ userId ─────┼──────────┘
│ items[]     │  │  │ quantity      │     │ items[]     │
│ updatedAt   │  │  │ price         │     │ address     │
└─────────────┘  │  └───────────────┘     │ payment     │
                 │                        │ status      │
                 │                        │ total       │
                 │                        │ createdAt   │
                 └────────────────────────┴─────────────┘
```

### Phone Categories
- `iPhone` - Apple iPhone series
- `Samsung` - Samsung Galaxy series
- `Xiaomi` - Xiaomi / Redmi / POCO
- `OPPO` - OPPO / Realme
- `Vivo` - Vivo series
- `Other` - Google Pixel, OnePlus, etc.

### JWT Token Strategy

```
┌──────────────┐                    ┌──────────────┐
│ Access Token │                    │Refresh Token │
├──────────────┤                    ├──────────────┤
│ Expires: 7d  │                    │ Expires: 30d │
│ In: Secure   │                    │ In: Secure   │
│    Storage   │                    │    Storage   │
│ Use: API     │                    │ Use: Refresh │
└──────────────┘                    └──────────────┘
        │                                   │
        ▼                                   ▼
   ┌─────────┐    Token expired?      ┌─────────┐
   │ Request ├───────────────────────►│ Refresh │
   │   API   │◄───────────────────────┤ Endpoint│
   └─────────┘    New access token    └─────────┘
```

### Folder Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js      # MongoDB connection
│   │   ├── cloudinary.js    # Cloudinary config
│   │   └── cors.js          # CORS settings
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── productController.js
│   │   ├── cartController.js
│   │   ├── orderController.js
│   │   ├── reviewController.js
│   │   └── uploadController.js
│   ├── middleware/
│   │   ├── auth.js          # JWT verification
│   │   ├── errorHandler.js  # Global error handler
│   │   └── validation.js    # Request validation
│   ├── models/
│   │   ├── User.js
│   │   ├── Product.js
│   │   ├── Cart.js
│   │   ├── Order.js
│   │   └── Review.js
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── productRoutes.js
│   │   ├── cartRoutes.js
│   │   ├── orderRoutes.js
│   │   ├── reviewRoutes.js
│   │   └── uploadRoutes.js
│   ├── utils/
│   │   ├── jwt.js           # Token helpers
│   │   └── response.js      # Standard response format
│   └── app.js               # Express app setup
├── .env.example
├── package.json
└── server.js                # Entry point
```

## API Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [...]
  }
}
```

### Pagination Response
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

## Flutter Integration Changes

### Environment Configuration
```env
# Flutter .env
API_BASE_URL=http://localhost:3000/api
CLOUDINARY_CLOUD_NAME=drpxqclmg
```

### Dio Interceptors
1. **AuthInterceptor**: Tự động thêm Bearer token
2. **RefreshInterceptor**: Tự động refresh token khi expired
3. **ErrorInterceptor**: Xử lý lỗi thống nhất

### Repository Pattern Update
```
MockDataSource (remove) ──► ApiClient (use real API)
                                  │
                                  ▼
                           ApiClientImpl
                           (with interceptors)
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| CORS issues trên Flutter Web | Cấu hình CORS middleware cẩn thận, test kỹ |
| Token storage trên Web | Dùng HttpOnly cookies hoặc memory cho access token |
| MongoDB connection limits (Atlas free tier) | Connection pooling, optimize queries |
| Cloudinary bandwidth limits | Optimize images, lazy loading |

## Migration Plan

### Phase 1: Backend Setup (Priority: High)
1. Setup Node.js project với Express
2. Cấu hình MongoDB Atlas connection
3. Implement User model + Auth endpoints
4. Test với Postman

### Phase 2: Core APIs (Priority: High)
1. Products CRUD
2. Cart operations
3. Orders management
4. Reviews

### Phase 3: Flutter Integration (Priority: High)
1. Update ApiClientImpl với real endpoints
2. Add interceptors
3. Update repositories
4. Test end-to-end

### Phase 4: Media & Polish (Priority: Medium)
1. Cloudinary integration
2. Image upload từ Flutter
3. Error handling improvements
4. Performance optimization

## Open Questions
1. ~~Cần admin panel không?~~ → Phase 2
2. ~~Payment integration?~~ → Phase 2, sau khi MVP stable
3. ~~Email notifications?~~ → Optional, có thể thêm sau
