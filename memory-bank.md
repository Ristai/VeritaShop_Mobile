# VeritaShop Memory Bank

## Tổng quan dự án
- **Tên:** VeritaShop - Ecommerce Mobile App
- **Công nghệ:** Flutter 3.8.1+ / Dart SDK ^3.8.1
- **Mô tả:** Ứng dụng thương mại điện tử với tích hợp AI Sentiment Analysis
- **State Management:** Provider (ChangeNotifier)
- **Architecture:** Clean Architecture

---

## 1. NHỮNG GÌ ĐÃ LÀM ĐƯỢC

### 1.1 Kiến trúc dự án (Clean Architecture)
```
lib/
├── core/
│   ├── constants/app_colors.dart      ✅ Định nghĩa màu sắc (Dark/Light Theme)
│   ├── theme/app_theme.dart           ✅ App Theme configuration (Dark & Light)
│   └── routes/app_routes.dart         ✅ Routing configuration
├── data/
│   ├── models/                        ✅ Data models (9 models)
│   ├── repositories/                  ✅ Business logic layer (4 repositories)
│   └── data_sources/                  ✅ Local & Remote data sources
└── presentation/
    ├── screens/                       ✅ UI screens (17 screens)
    ├── view_models/                   ✅ State management (11 view models)
    └── widgets/                       ✅ Reusable widgets (7 widgets)
```

### 1.2 Models (Data Layer)
| Model | File | Trạng thái |
|-------|------|------------|
| ProductModel | `data/models/product_model.dart` | ✅ Hoàn thành |
| CartModel & CartSummary | `data/models/cart_model.dart` | ✅ Hoàn thành |
| UserModel | `data/models/user_model.dart` | ✅ Hoàn thành |
| ReviewModel | `data/models/review_model.dart` | ✅ Hoàn thành |
| OrderModel | `data/models/order_model.dart` | ✅ Quản lý đơn hàng |
| AddressModel | `data/models/address_model.dart` | ✅ Quản lý địa chỉ giao hàng |
| TrendingTopicModel | `data/models/trending_topic_model.dart` | ✅ Hoàn thành |
| ActionCardModel | `data/models/action_card_model.dart` | ✅ Hoàn thành |
| InsightCardModel | `data/models/insight_card_model.dart` | ✅ Hoàn thành |

### 1.3 Repositories
| Repository | File | Chức năng |
|------------|------|-----------|
| ProductRepository | `data/repositories/product_repository.dart` | ✅ CRUD products, search, filter, sort |
| CartRepository | `data/repositories/cart_repository.dart` | ✅ Add, update, remove, clear cart |
| UserRepository | `data/repositories/user_repository.dart` | ✅ Login, Register (mock) |
| ReviewRepository | `data/repositories/review_repository.dart` | ✅ Reviews management |

### 1.4 Data Sources
| Data Source | File | Mô tả |
|-------------|------|-------|
| MockDataSource | `data/data_sources/local/mock_data_source.dart` | ✅ Mock data cho development |
| ApiClient (Abstract) | `data/data_sources/remote/api_client.dart` | ✅ Interface cho API |
| ApiClientImpl | `data/data_sources/remote/api_client_impl.dart` | ✅ Implementation với Dio |

### 1.5 ViewModels (State Management)
| ViewModel | File | Trạng thái |
|-----------|------|------------|
| AuthViewModel | `presentation/view_models/auth_view_model.dart` | ✅ Login/Register/Logout với Provider |
| ProductViewModel | `presentation/view_models/product_view_model.dart` | ✅ Hoàn thành |
| CartViewModel | `presentation/view_models/cart_view_model.dart` | ✅ Hoàn thành (ChangeNotifier) |
| WishlistViewModel | `presentation/view_models/wishlist_view_model.dart` | ✅ Quản lý danh sách yêu thích |
| OrderViewModel | `presentation/view_models/order_view_model.dart` | ✅ Quản lý đơn hàng và địa chỉ |
| ReviewViewModel | `presentation/view_models/review_view_model.dart` | ✅ Hoàn thành |
| TrendingTopicViewModel | `presentation/view_models/trending_topic_view_model.dart` | ✅ Hoàn thành |
| ActionCardViewModel | `presentation/view_models/action_card_view_model.dart` | ✅ Hoàn thành |
| InsightCardViewModel | `presentation/view_models/insight_card_view_model.dart` | ✅ Hoàn thành |
| SearchHistoryViewModel | `presentation/view_models/search_history_view_model.dart` | ✅ Lịch sử tìm kiếm |
| ThemeViewModel | `presentation/view_models/theme_view_model.dart` | ✅ Dark/Light mode toggle |

### 1.6 Screens (UI Layer)
| Screen | File | Chức năng |
|--------|------|-----------|
| SplashScreen | `presentation/screens/splash_screen.dart` | ✅ Màn hình khởi động với animation |
| OnboardingScreen | `presentation/screens/onboarding_screen.dart` | ✅ Giới thiệu ứng dụng (4 slides) |
| LoginScreen | `presentation/screens/login_screen.dart` | ✅ Form đăng nhập, validation, social login UI |
| RegisterScreen | `presentation/screens/register_screen.dart` | ✅ Form đăng ký, validation, terms |
| HomeScreen | `presentation/screens/home_screen.dart` | ✅ AI Dashboard với 4 tabs (Home, Analytics, Comments, Settings) |
| ProductListScreen | `presentation/screens/product_list_screen.dart` | ✅ Grid/List view, search, filter, sort, add to cart |
| ProductDetailScreen | `presentation/screens/product_detail_screen.dart` | ✅ Full page chi tiết sản phẩm, gallery, wishlist |
| CartScreen | `presentation/screens/cart_screen.dart` | ✅ Hiển thị giỏ hàng, update quantity, remove items |
| CheckoutScreen | `presentation/screens/checkout_screen.dart` | ✅ Quy trình thanh toán, địa chỉ, payment |
| OrderSuccessScreen | `presentation/screens/order_success_screen.dart` | ✅ Xác nhận đơn hàng thành công |
| OrderHistoryScreen | `presentation/screens/order_history_screen.dart` | ✅ Lịch sử đơn hàng, chi tiết, hủy đơn |
| WishlistScreen | `presentation/screens/wishlist_screen.dart` | ✅ Danh sách sản phẩm yêu thích |
| ProfileScreen | `presentation/screens/profile_screen.dart` | ✅ Thông tin user, thống kê, logout |
| WriteReviewScreen | `presentation/screens/write_review_screen.dart` | ✅ Form viết đánh giá sản phẩm |
| AnalyticsScreen | `presentation/screens/analytics_screen.dart` | ✅ Thống kê AI Sentiment Analysis |
| CommentsScreen | `presentation/screens/comments_screen.dart` | ✅ Quản lý bình luận với filter |
| SettingsScreen | `presentation/screens/settings_screen.dart` | ✅ Cài đặt ứng dụng, theme toggle |

### 1.7 Reusable Widgets
| Widget | File | Mô tả |
|--------|------|-------|
| ProductCard | `presentation/widgets/product_card.dart` | ✅ Card hiển thị sản phẩm |
| CustomButton | `presentation/widgets/custom_button.dart` | ✅ Button với loading state |
| CustomTextField | `presentation/widgets/custom_text_field.dart` | ✅ TextField với validation |
| SkeletonLoading | `presentation/widgets/skeleton_loading.dart` | ✅ Animated skeleton loading |
| SearchHistoryOverlay | `presentation/widgets/search_history_overlay.dart` | ✅ Overlay lịch sử tìm kiếm |
| ProductRecommendations | `presentation/widgets/product_recommendations.dart` | ✅ Gợi ý sản phẩm horizontal |
| ImageZoomViewer | `presentation/widgets/image_zoom_viewer.dart` | ✅ Full-screen image viewer với zoom |

### 1.8 Dependencies đã cài đặt
```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  google_fonts: ^6.3.2          # Typography
  provider: ^6.1.2              # State management
  dio: ^5.4.0                   # HTTP client
  shared_preferences: ^2.2.2    # Local storage
  flutter_secure_storage: ^9.0.0 # Secure storage
  flutter_dotenv: ^5.1.0        # Environment variables
  cached_network_image: ^3.3.1  # Image caching
  intl: ^0.19.0                 # Internationalization
```

### 1.9 Tính năng đã hoàn thành
- ✅ Dark/Light Theme UI hoàn chỉnh với toggle
- ✅ Routing configuration (11 routes)
- ✅ Đăng nhập / Đăng ký (mock validation)
- ✅ Hiển thị danh sách sản phẩm (Grid/List view)
- ✅ Tìm kiếm sản phẩm với lịch sử
- ✅ Lọc theo danh mục
- ✅ Sắp xếp sản phẩm
- ✅ Xem chi tiết sản phẩm (Full page)
- ✅ Thêm vào giỏ hàng
- ✅ Quản lý giỏ hàng (CRUD)
- ✅ Checkout flow hoàn chỉnh
- ✅ Order history với cancel order
- ✅ Wishlist management
- ✅ AI Dashboard với 4 tabs
- ✅ Analytics screen với sentiment analysis UI
- ✅ Comments management screen
- ✅ Settings screen với theme toggle
- ✅ Onboarding screens
- ✅ Splash screen với auto-check auth
- ✅ Skeleton loading
- ✅ Pull to refresh
- ✅ Image zoom/gallery
- ✅ Product recommendations
- ✅ Write review screen
- ✅ Mock data cho development

---

## 2. NHỮNG GÌ CHƯA LÀM ĐƯỢC (TODO)

### 2.1 Backend Integration
- ❌ Kết nối API thật (hiện đang dùng mock data)
- ❌ Authentication với JWT token
- ❌ Refresh token mechanism
- ❌ API error handling nâng cao

### 2.2 Tính năng chưa hoàn thành
- ❌ **Payment integration** - Tích hợp thanh toán thật (MoMo, VNPay, etc.)
- ❌ **Push notifications** - Thông báo đẩy
- ❌ **Order tracking** - Theo dõi đơn hàng real-time

### 2.3 UI/UX cần cải thiện
- ❌ Pagination cho danh sách sản phẩm
- ❌ Responsive design cho tablet
- ❌ Animation transitions giữa các màn hình

### 2.4 Performance & Optimization
- ❌ Image caching strategy nâng cao
- ❌ Lazy loading
- ❌ Code splitting
- ❌ Memory optimization

### 2.5 Testing
- ❌ Unit tests
- ❌ Widget tests
- ❌ Integration tests
- ❌ E2E tests

### 2.6 Security
- ❌ Input sanitization
- ❌ Secure API calls (HTTPS pinning)
- ❌ Biometric authentication
- ❌ Data encryption

### 2.7 Localization
- ❌ Multi-language support (hiện chỉ có tiếng Việt)
- ❌ RTL support

---

## 3. CẤU TRÚC FILE HIỆN TẠI

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── routes/
│   │   └── app_routes.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── data_sources/
│   │   ├── local/
│   │   │   └── mock_data_source.dart
│   │   └── remote/
│   │       ├── api_client.dart
│   │       └── api_client_impl.dart
│   ├── models/
│   │   ├── action_card_model.dart
│   │   ├── address_model.dart
│   │   ├── cart_model.dart
│   │   ├── insight_card_model.dart
│   │   ├── order_model.dart
│   │   ├── product_model.dart
│   │   ├── review_model.dart
│   │   ├── trending_topic_model.dart
│   │   └── user_model.dart
│   └── repositories/
│       ├── cart_repository.dart
│       ├── product_repository.dart
│       ├── review_repository.dart
│       └── user_repository.dart
└── presentation/
    ├── screens/
    │   ├── analytics_screen.dart
    │   ├── cart_screen.dart
    │   ├── checkout_screen.dart
    │   ├── comments_screen.dart
    │   ├── home_screen.dart
    │   ├── login_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── order_history_screen.dart
    │   ├── order_success_screen.dart
    │   ├── product_detail_screen.dart
    │   ├── product_list_screen.dart
    │   ├── profile_screen.dart
    │   ├── register_screen.dart
    │   ├── settings_screen.dart
    │   ├── splash_screen.dart
    │   ├── wishlist_screen.dart
    │   └── write_review_screen.dart
    ├── view_models/
    │   ├── action_card_view_model.dart
    │   ├── auth_view_model.dart
    │   ├── cart_view_model.dart
    │   ├── insight_card_view_model.dart
    │   ├── order_view_model.dart
    │   ├── product_view_model.dart
    │   ├── review_view_model.dart
    │   ├── search_history_view_model.dart
    │   ├── theme_view_model.dart
    │   ├── trending_topic_view_model.dart
    │   └── wishlist_view_model.dart
    └── widgets/
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── image_zoom_viewer.dart
        ├── product_card.dart
        ├── product_recommendations.dart
        ├── search_history_overlay.dart
        └── skeleton_loading.dart
```

---

## 4. ROUTING CONFIGURATION

```dart
// Routes được định nghĩa trong app_routes.dart
static const String splash = '/splash';        // SplashScreen
static const String onboarding = '/onboarding'; // OnboardingScreen
static const String login = '/login';          // LoginScreen
static const String register = '/register';    // RegisterScreen
static const String products = '/products';    // ProductListScreen
static const String home = '/home';            // HomeScreen (AI Dashboard)
static const String cart = '/cart';            // CartScreen
static const String profile = '/profile';      // ProfileScreen
static const String checkout = '/checkout';    // CheckoutScreen
static const String orders = '/orders';        // OrderHistoryScreen
static const String wishlist = '/wishlist';    // WishlistScreen
```

---

## 5. PROVIDER SETUP (main.dart)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeViewModel()),      // Dark/Light mode
    ChangeNotifierProvider(create: (_) => AuthViewModel()),       // Authentication
    ChangeNotifierProvider(create: (_) => CartViewModel()),       // Cart management
    ChangeNotifierProvider(create: (_) => WishlistViewModel()),   // Wishlist
    ChangeNotifierProvider(create: (_) => OrderViewModel()),      // Orders
    ChangeNotifierProvider(create: (_) => SearchHistoryViewModel()), // Search history
  ],
  ...
)
```

---

## 6. GHI CHÚ KỸ THUẬT

### Color Scheme
```dart
// Dark Theme
kBackgroundColorDark = Color(0xFF0A0E27)  // Nền chính
kCardColorDark = Color(0xFF1A1F3A)        // Card background
kBorderColorDark = Color(0xFF2A2F4A)      // Border

// Light Theme
kBackgroundColorLight = Color(0xFFF5F7FA) // Nền chính
kCardColorLight = Color(0xFFFFFFFF)       // Card background
kBorderColorLight = Color(0xFFE5E7EB)     // Border

// Accent Colors (cả 2 themes)
kAccentColor = Color(0xFF6366F1)          // Indigo - Primary
kGreenColor = Color(0xFF10B981)           // Success
kRedColor = Color(0xFFEF4444)             // Error
kYellowColor = Color(0xFFF59E0B)          // Warning
kPurpleColor = Color(0xFF8B5CF6)          // Purple
```

### API Base URL
- Được cấu hình trong `.env` file
- Sử dụng `flutter_dotenv` để load

### Secure Storage Keys
```dart
'user_token'    // JWT token
'user_id'       // User ID
'user_name'     // User name
'user_email'    // User email
'user_avatar'   // Avatar URL
```

### SharedPreferences Keys
```dart
'is_dark_mode'      // Theme preference
'has_seen_onboarding' // Onboarding status
'search_history'    // Search history list
```

---

## 7. HƯỚNG DẪN TIẾP TỤC PHÁT TRIỂN

### Ưu tiên cao:
1. Tích hợp API thật (backend)
2. Authentication với JWT token
3. Payment integration (MoMo, VNPay)

### Ưu tiên trung bình:
4. Push notifications
5. Order tracking real-time
6. Pagination cho danh sách sản phẩm

### Ưu tiên thấp:
7. Unit/Widget tests
8. Multi-language support
9. Performance optimization
10. Biometric authentication

---

**Cập nhật lần cuối:** 2025-12-14
