## 1. Backend Implementation

### 1.1 User Model
- [x] 1.1.1 Thêm fields `pinHash`, `pinEnabled` vào `User.js`

### 1.2 User Controller
- [x] 1.2.1 Tạo `setPin()` - POST /api/users/pin
- [x] 1.2.2 Tạo `verifyPin()` - POST /api/users/pin/verify
- [x] 1.2.3 Tạo `togglePin()` - PUT /api/users/pin/toggle
- [x] 1.2.4 Tạo `deletePin()` - DELETE /api/users/pin

### 1.3 User Routes
- [x] 1.3.1 Thêm routes cho PIN endpoints

## 2. Mobile Implementation

### 2.1 API Service
- [x] 2.1.1 Thêm `setPin()` method
- [x] 2.1.2 Thêm `verifyPinCloud()` method
- [x] 2.1.3 Thêm `togglePin()` method
- [x] 2.1.4 Thêm `deletePin()` method
- [x] 2.1.5 Thêm `getPinStatus()` method

### 2.2 PIN Service
- [x] 2.2.1 Cập nhật `setPin()` để gọi API
- [x] 2.2.2 Cập nhật `verifyPin()` để gọi API (fallback local)
- [x] 2.2.3 Cập nhật `enablePin()`/`disablePin()` để gọi API
- [x] 2.2.4 Thêm `syncFromCloud()` method

### 2.3 PIN ViewModel
- [x] 2.3.1 Cập nhật `checkPinStatus()` để lấy từ cloud
- [x] 2.3.2 Cập nhật các methods khác để sync

### 2.4 Settings Screen
- [x] 2.4.1 Thêm option "Đổi mã PIN" (khi PIN enabled) - Đã có từ trước
- [x] 2.4.2 Cập nhật toggle PIN để sync cloud - Đã được xử lý qua PinService

## 3. Testing
- [ ] 3.1 Test backend endpoints với Postman/curl
- [ ] 3.2 Test mobile flow: Setup PIN → Verify → Toggle → Delete
- [ ] 3.3 Test backward compatibility với user có local PIN
