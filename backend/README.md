---
noteId: "2f474940ddb711f0a4cff1c6086bb22a"
tags: []

---

# Backend - VeritaShop API

## Cài đặt

```bash
cd backend
npm install
```

## Cấu hình

Copy `.env.example` thành `.env` và cập nhật các giá trị:

```bash
cp .env.example .env
```

## Chạy server

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

## API Endpoints

### Health Check
- `GET /health` - Kiểm tra server status
- `GET /api` - Thông tin API

### Auth (Coming soon)
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/refresh` - Refresh token
- `POST /api/auth/logout` - Đăng xuất

### Products (Coming soon)
- `GET /api/products` - Danh sách điện thoại
- `GET /api/products/:id` - Chi tiết điện thoại
- `GET /api/products/search` - Tìm kiếm
- `GET /api/products/brand/:brand` - Lọc theo hãng
- `GET /api/products/featured` - Sản phẩm nổi bật

### Cart (Coming soon)
- `GET /api/cart` - Giỏ hàng
- `POST /api/cart` - Thêm vào giỏ
- `PUT /api/cart/:id` - Cập nhật số lượng
- `DELETE /api/cart/:id` - Xóa item

### Orders (Coming soon)
- `GET /api/orders` - Lịch sử đơn hàng
- `POST /api/orders` - Tạo đơn hàng
- `GET /api/orders/:id` - Chi tiết đơn hàng
- `PUT /api/orders/:id/cancel` - Hủy đơn hàng
