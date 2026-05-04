# Project Context

## Purpose
VeritaShop is a full-stack e-commerce mobile application for mobile phone sales, targeting the Vietnamese market. It consists of a Flutter mobile app and a Node.js backend API. The app provides a complete shopping experience including product browsing, cart management, wishlist, user authentication, order management, coupon system, reviews, and an admin dashboard with analytics.

## Tech Stack

### Mobile App (Flutter)
- **Framework**: Flutter (SDK ^3.8.1)
- **Language**: Dart
- **State Management**: Provider (^6.1.2)
- **HTTP Client**: Dio (^5.4.0)
- **Local Storage**: SharedPreferences (^2.2.2), FlutterSecureStorage (^9.0.0)
- **Environment Variables**: flutter_dotenv (^5.1.0)
- **UI/Styling**: Material Design, Google Fonts (^6.3.2), Cupertino Icons (^1.0.8)
- **Image Handling**: cached_network_image (^3.3.1), image_picker (^1.0.7)
- **Charts**: fl_chart (^1.1.1)
- **Internationalization**: intl (^0.19.0)
- **Linting**: flutter_lints (^5.0.0)

### Backend (Node.js)
- **Runtime**: Node.js (>=18.0.0)
- **Framework**: Express (^4.18.2)
- **Database**: MongoDB via Mongoose (^8.0.3)
- **Authentication**: JWT (jsonwebtoken ^9.0.2), bcryptjs (^2.4.3)
- **File Upload**: Multer (^1.4.5-lts.1), Cloudinary (^1.41.0)
- **Email**: Nodemailer (^7.0.12)
- **Validation**: express-validator (^7.0.1)
- **Dev Tools**: Nodemon (^3.0.2)

## Project Conventions

### Code Style
- Follow `flutter_lints` recommended rules defined in `analysis_options.yaml`
- Use Vietnamese comments for business logic documentation (e.g., `/// Model dữ liệu sản phẩm`)
- Use `const` constructors where possible (`const MyApp({super.key})`)
- Private members prefixed with underscore (`_currentUser`, `_isLoading`)
- Use getter methods for computed properties (`bool get isInStock => stock > 0`)

### Architecture Patterns

#### Mobile App (MVVM)
- **Pattern**: MVVM with Provider for state management
- **Folder Structure**:
  - `lib/core/` - Constants, routes, theme, network configuration
  - `lib/data/` - Data layer (models, repositories, data_sources)
  - `lib/presentation/` - UI layer (screens, view_models, widgets)
- **Naming Conventions**:
  - Screens: `*_screen.dart` (e.g., `home_screen.dart`)
  - ViewModels: `*_view_model.dart` (e.g., `auth_view_model.dart`)
  - Models: `*_model.dart` (e.g., `product_model.dart`)
  - Widgets: `*_widget.dart` or descriptive names (e.g., `product_card.dart`)
- **Route Management**: Centralized in `AppRoutes` class with named routes

#### Backend (MVC-like)
- **Pattern**: Controller-based architecture with Express
- **Folder Structure**:
  - `backend/src/config/` - Database, CORS, Cloudinary configuration
  - `backend/src/controllers/` - Request handlers (authController, productController, etc.)
  - `backend/src/middleware/` - Auth, validation, error handling middleware
  - `backend/src/models/` - Mongoose schemas (User, Product, Order, Cart, Review, Coupon)
  - `backend/src/routes/` - API route definitions
  - `backend/src/utils/` - Helpers (JWT, email service, response formatting)
- **Naming Conventions**:
  - Controllers: `*Controller.js` (e.g., `authController.js`)
  - Models: PascalCase (e.g., `User.js`, `Product.js`)
  - Routes: `*Routes.js` (e.g., `authRoutes.js`)

### Testing Strategy
- **Mobile**: Widget tests in `test/` directory
  - Run tests: `flutter test`
  - Run analyzer: `flutter analyze`
- **Backend**: Manual testing (no automated tests configured)
  - Run dev server: `npm run dev`
  - Seed database: `npm run seed`

### Git Workflow
- Main branch: `main`
- Feature branches: `main#feature-*` or `main#frontend-*`
- Merge via pull requests

## Domain Context
- **Product Type**: Mobile phones / electronics
- **Currency**: Vietnamese Dong (VNĐ) - prices formatted as K/M đ
- **Target Market**: Vietnamese e-commerce users
- **User Roles**: Customer, Admin
- **Key Features**:
  - Product catalog with categories, ratings, reviews
  - Shopping cart and wishlist functionality
  - User authentication (login/register/forgot password)
  - Order management and history
  - Coupon/discount system
  - Admin dashboard with:
    - Product management (CRUD)
    - Order management
    - User management
    - Coupon management
    - Review moderation
    - Sales reports and analytics
  - Dark/Light theme support
  - Onboarding flow for new users

## Important Constraints
- **Mobile App**:
  - Private package (not published to pub.dev)
  - iOS builds require macOS with Xcode and CocoaPods
  - Sensitive data must use `flutter_secure_storage`
  - Environment variables loaded from `.env` file (included as asset)
- **Backend**:
  - Requires MongoDB connection (configured via environment variables)
  - Cloudinary account required for image uploads
  - Node.js >= 18.0.0 required

## External Dependencies
- **Image Storage**: Cloudinary (cloud-based image CDN)
- **Database**: MongoDB (external service)
- **Email Service**: SMTP via Nodemailer (for password reset, etc.)
- **Backend API**: Express.js REST API at configurable base URL
- **Authentication**: JWT-based with tokens stored in secure storage (mobile) / HTTP headers (API)
