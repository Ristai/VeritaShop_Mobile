---
noteId: "0b3e6ed0e1d511f0a09a0746eeb1a77d"
tags: []

---

# BÀN GIAO DỰ ÁN - VeritaShop E-commerce App

## TỔNG QUAN ĐÃ LÀM

### 1. Backend (Node.js/Express + MongoDB)
- **Authentication**: Đăng ký, đăng nhập, quên/reset mật khẩu với JWT
- **Products API**: CRUD sản phẩm, tìm kiếm, lọc, phân trang
- **Cart API**: Thêm/xóa/cập nhật giỏ hàng
- **Orders API**: Đặt hàng, xem lịch sử, hủy đơn, đặt lại
- **Admin API**: Dashboard thống kê, quản lý products/orders/users/coupons/reviews
- **Upload**: Tích hợp Cloudinary cho upload ảnh

### 2. Flutter App (Customer)
- Đăng ký/đăng nhập/quên mật khẩu
- Xem sản phẩm, tìm kiếm, lọc theo brand/giá
- Chi tiết sản phẩm với specs
- Giỏ hàng và Wishlist
- Đặt hàng với mã giảm giá
- Xem lịch sử đơn hàng (đã sync status với admin)
- Đánh giá sản phẩm
- Dark/Light mode

### 3. Admin Dashboard (trong app Flutter)
- Dashboard thống kê doanh thu
- Quản lý sản phẩm (CRUD + upload ảnh)
- Quản lý đơn hàng (cập nhật trạng thái với optimistic update)
- Quản lý người dùng
- Quản lý mã giảm giá
- Quản lý đánh giá
- Báo cáo

### 4. Các fix gần đây
- **Optimistic update** cho admin orders - UI mượt hơn khi đổi status
- **Sync status** giữa admin và user - thêm các status: `shipped`, `completed`, `refunded`
- Fix duplicate code trong admin_orders_screen

---

## HƯỚNG DẪN CÀI ĐẶT

### Yêu cầu
- **Node.js** 18+
- **MongoDB** (local hoặc Atlas)
- **Flutter SDK** 3.8.1+
- **Cloudinary** account (free)

### Bước 1: Clone và cài Backend

```bash
git clone <repo-url>
cd VeritaShop-Ecommerce-MobileApp

# Cài backend
cd backend
npm install
```

### Bước 2: Tạo file `backend/.env`

```env
PORT=3000
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/veritashop?retryWrites=true&w=majority
JWT_SECRET=your_secret_key_here

# Cloudinary (tạo account free tại cloudinary.com)
CLOUDINARY_CLOUD_NAME=xxx
CLOUDINARY_API_KEY=xxx
CLOUDINARY_API_SECRET=xxx

# Email (tùy chọn - cho quên mật khẩu)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
```

### Cách lấy MongoDB Atlas URI (QUAN TRỌNG)

Dự án đang dùng **MongoDB Atlas** (cloud database). Có 2 cách:

**Cách 1: Dùng chung database hiện tại (hỏi người bàn giao)**
- Liên hệ người bàn giao để lấy `MONGODB_URI` đầy đủ
- Hoặc được thêm vào Atlas project với quyền truy cập

**Cách 2: Tạo MongoDB Atlas mới (miễn phí)**

1. Vào https://cloud.mongodb.com → Đăng ký/Đăng nhập
2. Tạo cluster mới (chọn FREE tier M0)
3. Vào **Database Access** → Add Database User:
   - Username: `veritashop`
   - Password: tự đặt (nhớ lưu lại)
4. Vào **Network Access** → Add IP Address:
   - Chọn "Allow Access from Anywhere" (0.0.0.0/0) để dev
5. Vào **Database** → Click "Connect" → "Connect your application"
6. Copy connection string, thay `<username>`, `<password>`:
   ```
   mongodb+srv://veritashop:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/veritashop?retryWrites=true&w=majority
   ```
7. Dán vào `MONGODB_URI` trong file `.env`
8. Chạy `npm run seed` để tạo dữ liệu mẫu

### Bước 3: Seed database và chạy Backend

```bash
# Seed dữ liệu mẫu
npm run seed

# Chạy server
npm run dev
```

Backend chạy tại: `http://localhost:3000`

### Bước 4: Cài Flutter

```bash
cd ..
flutter pub get
```

### Bước 5: Tạo file `.env` ở thư mục gốc

```env
API_BASE_URL=http://localhost:3000/api
```

> **Lưu ý**: Nếu chạy trên thiết bị thật, đổi `localhost` thành IP máy tính (ví dụ: `http://192.168.1.100:3000/api`)

### Bước 6: Chạy app

```bash
# Web
flutter run -d chrome

# Android (cần Android Studio + Emulator)
flutter run -d android

# iOS (macOS + Xcode)
cd ios && pod install && cd ..
flutter run -d ios
```

---

## TÀI KHOẢN TEST

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@veritashop.com | Admin@123 |
| User | user@veritashop.com | User@123 |

---

## CẤU TRÚC CODE CHÍNH

```
backend/
├── src/
│   ├── controllers/      # Xử lý logic API
│   ├── middleware/       # Auth, admin check
│   ├── models/           # MongoDB schemas
│   ├── routes/           # Định nghĩa routes
│   └── utils/seed.js     # Tạo data mẫu

lib/
├── core/
│   ├── network/api_service.dart    # Gọi API
│   └── routes/app_routes.dart      # Navigation
├── data/
│   ├── models/                     # Data models
│   └── repositories/               # Data layer
└── presentation/
    ├── screens/                    # UI screens
    │   └── admin/                  # Admin dashboard
    └── view_models/                # State (Provider)
```

---

## CẦN LÀM TIẾP (GỢI Ý)

- [ ] Push notification khi đơn hàng thay đổi trạng thái
- [ ] Realtime update với WebSocket
- [ ] Tích hợp thanh toán (VNPay, MoMo, ZaloPay)
- [ ] Chat hỗ trợ khách hàng
- [ ] Tối ưu performance (lazy loading, caching)
- [ ] Unit tests và integration tests
- [ ] Deploy backend lên hosting (Railway, Render, AWS)
- [ ] Build app release (APK, IPA)

---

## LIÊN HỆ

Nếu có thắc mắc về code, liên hệ người bàn giao.
