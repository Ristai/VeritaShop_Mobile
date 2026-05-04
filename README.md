# VeritaShop - Ứng dụng Thương mại Điện tử

Ứng dụng thương mại điện tử điện thoại di động được xây dựng bằng Flutter với Backend Node.js/Express, nhắm đến thị trường Việt Nam.

## Tính năng chính

### Khách hàng
- **Xác thực**: Đăng ký/Đăng nhập với JWT, Quên mật khẩu qua email
- **Sản phẩm**: Xem danh sách, tìm kiếm server-side, lọc theo brand/giá/tình trạng
- **Chi tiết sản phẩm**: Thông số kỹ thuật, hình ảnh, đánh giá
- **Giỏ hàng & Wishlist**: Quản lý sản phẩm yêu thích và giỏ hàng
- **Đặt hàng**: Thanh toán COD, áp dụng mã giảm giá
- **Quản lý địa chỉ**: Thêm/Sửa/Xóa địa chỉ giao hàng, đặt mặc định
- **Lịch sử đơn hàng**: Xem chi tiết, hủy đơn, đặt lại
- **Đánh giá sản phẩm**:
  - Viết review với rating 1-5 sao
  - Upload hình ảnh kèm đánh giá (tối đa 5 ảnh)
  - Phân tích cảm xúc tự động (ABSA - Aspect-Based Sentiment Analysis)
- **Giao diện**: Dark/Light mode, hoàn toàn bằng tiếng Việt
- **Thông báo**: Local notifications cho đơn hàng mới, nhắc đánh giá

### Admin Dashboard
- **Quản lý sản phẩm**: CRUD với upload ảnh lên Cloudinary
- **Quản lý đơn hàng**: Cập nhật trạng thái (pending → confirmed → shipping → delivered)
- **Quản lý người dùng**: Xem, khóa/mở khóa tài khoản
- **Quản lý mã giảm giá**: Tạo coupon với điều kiện áp dụng
- **Quản lý đánh giá**:
  - Kiểm duyệt nội dung (chờ duyệt/đã duyệt/từ chối)
  - Lọc nội dung không phù hợp tự động
- **Báo cáo**: Doanh thu, thống kê sản phẩm bán chạy, xu hướng

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
│   │   ├── middleware/      # Auth, admin, content filter
│   │   ├── models/          # Mongoose schemas
│   │   ├── routes/          # API routes
│   │   └── utils/           # Helpers, seed, sentiment
│   └── server.js
│
├── lib/                     # Flutter app
│   ├── core/
│   │   ├── constants/       # Colors, config
│   │   ├── network/         # API service, interceptors
│   │   ├── routes/          # App routing
│   │   ├── services/        # Local notifications
│   │   ├── utils/           # Currency formatter
│   │   └── theme/           # Dark/Light themes
│   ├── data/
│   │   ├── models/          # Data models
│   │   └── repositories/    # Data layer
│   └── presentation/
│       ├── screens/         # UI screens
│       │   └── admin/       # Admin dashboard
│       ├── view_models/     # State management (Provider)
│       └── widgets/         # Reusable widgets
```

## API Endpoints

### Auth
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/forgot-password` - Quên mật khẩu
- `POST /api/auth/reset-password` - Đặt lại mật khẩu
- `GET /api/auth/me` - Lấy thông tin user

### Products
- `GET /api/products` - Danh sách sản phẩm (hỗ trợ search, filter, pagination)
- `GET /api/products/search?q=keyword` - Tìm kiếm server-side
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
- `PUT /api/orders/:id/cancel` - Hủy đơn hàng

### Reviews
- `POST /api/reviews` - Tạo đánh giá (tự động phân tích sentiment ABSA)
- `GET /api/reviews/product/:productId` - Lấy đánh giá theo sản phẩm
- `GET /api/reviews/my-reviews` - Lấy đánh giá của user
- `PUT /api/reviews/:id` - Cập nhật đánh giá
- `DELETE /api/reviews/:id` - Xóa đánh giá
- `POST /api/reviews/:id/like` - Like đánh giá

### User Profile
- `GET /api/auth/profile` - Lấy profile với địa chỉ
- `POST /api/auth/addresses` - Thêm địa chỉ
- `PUT /api/auth/addresses/:id` - Cập nhật địa chỉ
- `DELETE /api/auth/addresses/:id` - Xóa địa chỉ

### Admin
- `GET /api/admin/dashboard` - Thống kê tổng quan
- `GET/POST/PUT/DELETE /api/admin/products` - CRUD sản phẩm
- `GET/PUT /api/admin/orders` - Quản lý đơn hàng
- `GET/PUT/DELETE /api/admin/users` - Quản lý users
- `GET/POST/PUT/DELETE /api/admin/coupons` - Quản lý mã giảm giá
- `GET /api/admin/reports/*` - Báo cáo doanh thu

### Admin - Review Moderation
- `GET /api/admin/reviews` - Danh sách tất cả đánh giá
- `GET /api/admin/reviews/flagged` - Đánh giá bị flag (cần kiểm duyệt)
- `GET /api/admin/reviews/moderation-categories` - Danh mục vi phạm
- `PUT /api/admin/reviews/:id/approve` - Duyệt đánh giá
- `PUT /api/admin/reviews/:id/moderation/approve` - Duyệt sau kiểm duyệt
- `PUT /api/admin/reviews/:id/moderation/reject` - Từ chối đánh giá
- `DELETE /api/admin/reviews/:id` - Xóa đánh giá

### Upload
- `POST /api/upload/image` - Upload 1 ảnh lên Cloudinary
- `POST /api/upload/images` - Upload nhiều ảnh
- `POST /api/upload/review-images` - Upload ảnh đánh giá

## Tech Stack

### Frontend
- **Framework**: Flutter 3.8.1+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Storage**: SharedPreferences, FlutterSecureStorage
- **Images**: Image Picker, Cached Network Image
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications
- **Internationalization**: intl

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB + Mongoose
- **Authentication**: JWT (jsonwebtoken)
- **Image Storage**: Cloudinary
- **Email**: Nodemailer
- **File Upload**: Multer
- **Validation**: express-validator

## Screenshots

### Customer App
| Trang chủ | Chi tiết sản phẩm | Giỏ hàng |
|-----------|-------------------|----------|
| Danh sách sản phẩm với search | Thông tin, specs, reviews | Quản lý số lượng, thanh toán |

| Thanh toán | Đơn hàng | Đánh giá |
|------------|----------|----------|
| Chọn địa chỉ, mã giảm giá | Lịch sử, chi tiết | Upload ảnh, sentiment |

### Admin Dashboard
| Dashboard | Quản lý sản phẩm | Quản lý đơn hàng |
|-----------|------------------|------------------|
| Thống kê, biểu đồ | CRUD, upload ảnh | Cập nhật trạng thái |

## Đóng góp

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## License

MIT License - xem file [LICENSE](LICENSE) để biết thêm chi tiết.
