# VeritaShop - Ecommerce Mobile App

Ứng dụng thương mại điện tử điện thoại di động được xây dựng bằng Flutter với Backend Node.js/Express.

## Tính năng chính

### Khách hàng
- Đăng ký/Đăng nhập với JWT Authentication
- Quên mật khẩu (gửi email reset)
- Xem danh sách sản phẩm, tìm kiếm, lọc theo brand/giá/tình trạng
- Xem chi tiết sản phẩm với thông số kỹ thuật
- Giỏ hàng và Wishlist
- Đặt hàng với mã giảm giá
- Xem lịch sử đơn hàng, đặt lại đơn
- Viết đánh giá sản phẩm
- Dark/Light mode

### Admin Dashboard
- Quản lý sản phẩm (CRUD) với upload ảnh lên Cloudinary
- Quản lý đơn hàng, cập nhật trạng thái
- Quản lý người dùng
- Quản lý mã giảm giá
- Quản lý đánh giá
- Báo cáo doanh thu, thống kê

## Yêu cầu hệ thống

### Frontend (Flutter)
- **Flutter SDK** 3.8.1+
- **Dart SDK** 3.8.1+
- **macOS + Xcode** (cho iOS)
- **Android Studio** (cho Android)

### Backend (Node.js)
- **Node.js** 18.0.0+
- **MongoDB** (local hoặc MongoDB Atlas)
- **Cloudinary** account (để upload ảnh)

## Cài đặt

### 1. Clone repository
```bash
git clone <repo-url>
cd VeritaShop-Ecommerce-MobileApp
```

### 2. Cấu hình Backend

```bash
cd backend
npm install
```

Tạo file `.env` trong thư mục `backend/`:
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/veritashop
JWT_SECRET=your_jwt_secret_key

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Email (cho Forgot Password)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
```

Seed database với dữ liệu mẫu:
```bash
npm run seed
```

Chạy backend:
```bash
npm run dev
```

Backend sẽ chạy tại `http://localhost:3000`

### 3. Cấu hình Flutter

```bash
cd ..
flutter pub get
```

Tạo file `.env` ở thư mục gốc:
```env
API_BASE_URL=http://localhost:3000/api
```

### 4. Chạy ứng dụng

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS (macOS only)
cd ios && pod install && cd ..
flutter run -d ios
```

## Tài khoản mặc định

Sau khi chạy `npm run seed`:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@veritashop.com | Admin@123 |
| Customer | user@veritashop.com | User@123 |

## Cấu trúc dự án

```
├── backend/                 # Node.js/Express API
│   ├── src/
│   │   ├── controllers/     # Route handlers
│   │   ├── middleware/      # Auth, admin middleware
│   │   ├── models/          # Mongoose schemas
│   │   ├── routes/          # API routes
│   │   └── utils/           # Helpers, seed
│   └── server.js
│
├── lib/                     # Flutter app
│   ├── core/
│   │   ├── constants/       # Colors, config
│   │   ├── network/         # API service, interceptors
│   │   ├── routes/          # App routing
│   │   └── theme/           # Dark/Light themes
│   ├── data/
│   │   ├── models/          # Data models
│   │   └── repositories/    # Data layer
│   └── presentation/
│       ├── screens/         # UI screens
│       │   └── admin/       # Admin dashboard
│       ├── view_models/     # State management
│       └── widgets/         # Reusable widgets
│
└── openspec/                # API specifications
```

## API Endpoints

### Auth
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/forgot-password` - Quên mật khẩu
- `POST /api/auth/reset-password` - Đặt lại mật khẩu
- `GET /api/auth/me` - Lấy thông tin user

### Products
- `GET /api/products` - Danh sách sản phẩm
- `GET /api/products/:id` - Chi tiết sản phẩm
- `GET /api/products/:id/reviews` - Đánh giá sản phẩm

### Cart
- `GET /api/cart` - Xem giỏ hàng
- `POST /api/cart/add` - Thêm vào giỏ
- `PUT /api/cart/update` - Cập nhật số lượng
- `DELETE /api/cart/remove/:productId` - Xóa sản phẩm

### Orders
- `POST /api/orders` - Tạo đơn hàng
- `GET /api/orders` - Lịch sử đơn hàng
- `GET /api/orders/:id` - Chi tiết đơn hàng

### Admin
- `GET /api/admin/dashboard` - Thống kê tổng quan
- `GET/POST/PUT/DELETE /api/admin/products` - CRUD sản phẩm
- `GET/PUT /api/admin/orders` - Quản lý đơn hàng
- `GET/PUT/DELETE /api/admin/users` - Quản lý users
- `GET/POST/PUT/DELETE /api/admin/coupons` - Quản lý mã giảm giá
- `GET/PUT/DELETE /api/admin/reviews` - Quản lý đánh giá
- `GET /api/admin/reports/*` - Báo cáo

### Upload
- `POST /api/upload/image` - Upload 1 ảnh lên Cloudinary
- `POST /api/upload/images` - Upload nhiều ảnh

## Tech Stack

### Frontend
- Flutter 3.8.1+
- Provider (State Management)
- Dio (HTTP Client)
- SharedPreferences + FlutterSecureStorage
- Image Picker
- Cached Network Image

### Backend
- Node.js + Express
- MongoDB + Mongoose
- JWT Authentication
- Cloudinary (Image Storage)
- Nodemailer (Email)
- Multer (File Upload)

## License

MIT License
