---
noteId: "86983864ddb411f0a4cff1c6086bb22a"
tags: []

---

## MODIFIED Requirements

### Requirement: API Client Configuration
The Flutter app SHALL connect to real backend API instead of mock data.

#### Scenario: Initialize with environment config
- **WHEN** app starts
- **THEN** ApiClientImpl reads API_BASE_URL from .env file
- **AND** configures Dio with base URL, timeouts, and headers

#### Scenario: CORS support for Flutter Web
- **WHEN** running on Flutter Web
- **THEN** API requests include proper CORS headers
- **AND** backend accepts requests from web origin

---

### Requirement: JWT Token Management
The Flutter app SHALL manage JWT tokens automatically.

#### Scenario: Attach token to requests
- **WHEN** user is authenticated
- **THEN** AuthInterceptor adds Bearer token to all API requests

#### Scenario: Token refresh on 401
- **WHEN** API returns 401 with code "TOKEN_EXPIRED"
- **THEN** RefreshInterceptor automatically calls /api/auth/refresh
- **AND** retries original request with new access token
- **AND** if refresh fails, logs out user and redirects to login

#### Scenario: Token storage
- **WHEN** user logs in
- **THEN** access token stored in memory (for security)
- **AND** refresh token stored in FlutterSecureStorage

---

### Requirement: Repository Layer Integration
The repositories SHALL use ApiClient instead of MockDataSource.

#### Scenario: ProductRepository uses API
- **WHEN** ProductRepository.getAllProducts() is called
- **THEN** it calls ApiClientImpl.getProducts()
- **AND** maps response to List<ProductModel>

#### Scenario: CartRepository uses API
- **WHEN** CartRepository methods are called
- **THEN** they call corresponding ApiClientImpl cart endpoints
- **AND** cart state syncs with server

#### Scenario: Fallback to cached data
- **WHEN** API call fails due to network error
- **THEN** repository can optionally return cached local data
- **AND** shows error message to user

---

### Requirement: Error Handling
The Flutter app SHALL handle API errors gracefully.

#### Scenario: Network error
- **WHEN** device has no internet connection
- **THEN** ErrorInterceptor catches error
- **AND** shows user-friendly message "Không có kết nối mạng"

#### Scenario: Server error (5xx)
- **WHEN** API returns 500 error
- **THEN** shows message "Lỗi server, vui lòng thử lại sau"

#### Scenario: Validation error (400)
- **WHEN** API returns 400 with validation errors
- **THEN** displays specific error messages from response

---

### Requirement: Loading States
The Flutter app SHALL show loading indicators during API calls.

#### Scenario: Loading indicator
- **WHEN** API request is in progress
- **THEN** ViewModel sets isLoading = true
- **AND** UI shows loading indicator or skeleton

#### Scenario: Loading complete
- **WHEN** API request completes (success or error)
- **THEN** ViewModel sets isLoading = false
- **AND** UI updates with data or error message

---

## ADDED Requirements

### Requirement: Dio Interceptors
The Flutter app SHALL use Dio interceptors for cross-cutting concerns.

#### Scenario: Request logging (debug)
- **WHEN** in debug mode
- **THEN** LogInterceptor logs request URL, headers, and body

#### Scenario: Response logging (debug)
- **WHEN** in debug mode
- **THEN** LogInterceptor logs response status and data

---

### Requirement: Image Upload from Flutter
The Flutter app SHALL support image upload to Cloudinary via backend.

#### Scenario: Upload avatar
- **WHEN** user selects image for avatar
- **THEN** app sends multipart/form-data to /api/users/avatar
- **AND** backend uploads to Cloudinary
- **AND** returns Cloudinary URL
- **AND** app updates user avatar URL

#### Scenario: Upload review image
- **WHEN** user attaches image to review
- **THEN** app uploads image via /api/upload/image
- **AND** includes returned URL in review submission
