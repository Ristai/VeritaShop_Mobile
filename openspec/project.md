# Project Context

## Purpose
VeritaShop is a cross-platform e-commerce mobile application built with Flutter. The app provides a complete shopping experience including product browsing, cart management, wishlist, user authentication, order management, and analytics features. It supports both light and dark themes.

## Tech Stack
- **Framework**: Flutter (SDK ^3.8.1)
- **Language**: Dart
- **State Management**: Provider (^6.1.2)
- **HTTP Client**: Dio (^5.4.0)
- **Local Storage**: SharedPreferences, FlutterSecureStorage (for sensitive data)
- **Environment Variables**: flutter_dotenv
- **UI/Styling**: Material Design, Google Fonts (^6.3.2)
- **Image Caching**: cached_network_image (^3.3.1)
- **Internationalization**: intl (^0.19.0)
- **Linting**: flutter_lints (^5.0.0)

## Project Conventions

### Code Style
- Follow `flutter_lints` recommended rules defined in `analysis_options.yaml`
- Use Vietnamese comments for business logic documentation (e.g., `/// Model dữ liệu sản phẩm`)
- Use `const` constructors where possible (`const MyApp({super.key})`)
- Private members prefixed with underscore (`_currentUser`, `_isLoading`)
- Use getter methods for computed properties (`bool get isInStock => stock > 0`)

### Architecture Patterns
- **MVVM Pattern** with Provider for state management
- **Folder Structure**:
  - `lib/core/` - Constants, routes, theme configuration
  - `lib/data/` - Data layer (models, repositories, data_sources)
  - `lib/presentation/` - UI layer (screens, view_models, widgets)
- **Naming Conventions**:
  - Screens: `*_screen.dart` (e.g., `home_screen.dart`)
  - ViewModels: `*_view_model.dart` (e.g., `auth_view_model.dart`)
  - Models: `*_model.dart` (e.g., `product_model.dart`)
- **Route Management**: Centralized in `AppRoutes` class with named routes

### Testing Strategy
- Widget tests located in `test/` directory
- Run tests with `flutter test`
- Run analyzer with `flutter analyze`

### Git Workflow
- Main branch: `main`
- Feature branches: `main#feature-*` or `main#frontend-*`
- Merge via pull requests

## Domain Context
- **Currency**: Vietnamese Dong (VNĐ) - prices formatted as K/M đ
- **Target Market**: Vietnamese e-commerce users
- **Key Features**:
  - Product catalog with categories, ratings, reviews
  - Shopping cart and wishlist functionality
  - User authentication (login/register)
  - Order management and history
  - Analytics dashboard
  - Dark/Light theme support
  - Onboarding flow for new users

## Important Constraints
- Private package (not published to pub.dev)
- iOS builds require macOS with Xcode and CocoaPods
- Sensitive data must use `flutter_secure_storage`
- Environment variables loaded from `.env` file

## External Dependencies
- **Image CDN**: Uses external image URLs (pravatar.cc for avatars)
- **Backend API**: Ready for integration via Dio (currently uses mock data)
- **Authentication**: Token-based auth stored in secure storage
