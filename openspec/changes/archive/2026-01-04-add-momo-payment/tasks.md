# Tasks: Add MoMo Payment Integration

## Phase 1: Backend Infrastructure

### 1.1 Create Payment Model
- [x] Tạo file `backend/src/models/Payment.js`
- [x] Define schema với các fields: order, user, method, requestId, momoOrderId, amount, status, resultCode, transId, payUrl, deeplink, timestamps
- [x] Add indexes cho order, momoOrderId, requestId
- [x] Export model

### 1.2 Create MoMo Service
- [x] Tạo file `backend/src/services/momoService.js`
- [x] Implement `generateSignature(rawSignature, secretKey)` sử dụng HMAC SHA256
- [x] Implement `createPayment(orderId, amount, orderInfo, extraData)` - gọi MoMo API create
- [x] Implement `verifySignature(ipnBody)` - verify IPN callback
- [x] Implement `queryTransactionStatus(orderId, requestId)` - query status API
- [x] Add environment variable validation

### 1.3 Create Payment Controller
- [x] Tạo file `backend/src/controllers/paymentController.js`
- [x] Implement `POST /api/payments/momo/create` endpoint
  - Validate order belongs to user
  - Validate order not already paid
  - Call MoMo service to create payment
  - Save Payment record với status pending
  - Return payUrl và deeplink
- [x] Implement `POST /api/payments/momo/ipn` endpoint
  - Verify signature
  - Update Payment record
  - Update Order paymentStatus
  - Return 204 No Content to MoMo
- [x] Implement `GET /api/payments/momo/status/:orderId` endpoint
  - Query from database first
  - If pending, query MoMo API
  - Return current status
- [x] Implement `GET /api/payments/:orderId` endpoint
  - Return payment details for order

### 1.4 Create Payment Routes
- [x] Tạo file `backend/src/routes/paymentRoutes.js`
- [x] Define routes với authentication middleware (trừ IPN)
- [x] Register routes trong `app.js`

### 1.5 Update Order Model
- [x] Add `payment` field (ObjectId ref to Payment)
- [x] Add `paymentStatus` field (enum: pending, paid, failed)
- [x] Update createOrder to handle MoMo payment method

### 1.6 Update Order Controller
- [x] Modify `createOrder` để:
  - Nếu paymentMethod = 'MoMo', không clear cart ngay (chờ payment thành công)
  - Return orderId và requiresPayment flag để frontend gọi create payment

### 1.7 Add Environment Configuration
- [ ] Add MoMo env variables to `.env.example`
- [ ] Document required variables trong README

---

## Phase 2: Flutter App Implementation

### 2.1 Create Payment Service
- [x] Tạo file `lib/core/services/momo_service.dart`
- [x] Implement `createPayment(orderId, amount)` - call backend API
- [x] Implement `checkPaymentStatus(orderId)` - call backend API
- [x] Implement `handleMomoCallback(uri)` - parse deep link callback

### 2.2 Create Payment Models
- [x] Tạo file `lib/data/models/payment_model.dart`
- [x] Define `PaymentModel` class
- [x] Define `MomoPaymentResponse` class
- [x] Define `PaymentStatus` enum

### 2.3 Create Payment Repository
- [x] MomoService handles repository functions directly via ApiService (no separate repository needed)

### 2.4 Update ApiService
- [x] Add `createMomoPayment(orderId, amount)` method
- [x] Add `checkMomoPaymentStatus(orderId)` method
- [x] Add `getPaymentByOrder(orderId)` method

### 2.5 Create Payment ViewModel
- [x] Tạo file `lib/presentation/view_models/payment_view_model.dart`
- [x] Manage payment state (loading, error, success)
- [x] Implement `initiateMomoPayment(orderId, amount)`
- [x] Implement `checkPaymentStatus(orderId)`
- [x] Handle deep link callback

### 2.6 Configure Android Deep Links
- [x] Update `android/app/src/main/AndroidManifest.xml`
- [x] Add intent-filter cho `veritashop://momo-return`
- [ ] Verify deep link hoạt động

### 2.7 Update Checkout Screen
- [x] Import PaymentViewModel
- [x] Modify `_placeOrder()` method:
  - Nếu MoMo: create order → navigate to payment processing screen
  - Nếu COD: giữ nguyên flow hiện tại
- [x] Add loading state cho payment processing
- [x] Update button text for MoMo ("Thanh toán với MoMo")
- [x] Update payment label for MoMo ("Ví MoMo")

### 2.8 Create Payment Processing Screen
- [x] Tạo file `lib/presentation/screens/payment_processing_screen.dart`
- [x] Hiển thị loading khi khởi tạo payment
- [x] Hiển thị trạng thái chờ thanh toán
- [x] Hiển thị kết quả (success/failed)
- [x] Auto-check status với polling
- [x] Retry và cancel options

### 2.9 Handle Deep Link Navigation
- [x] Update `main.dart` để handle incoming deep links
- [x] Add PaymentViewModel to providers
- [x] Add app_links và url_launcher dependencies to pubspec.yaml
- [x] Parse result từ URL parameters

---

## Phase 3: Testing & Validation

### 3.1 Backend Unit Tests
- [ ] Test MoMo service signature generation
- [ ] Test IPN signature verification
- [ ] Test payment controller endpoints

### 3.2 Integration Tests
- [ ] Test full payment flow với MoMo sandbox
- [ ] Test IPN handling
- [ ] Test error scenarios (cancel, insufficient funds)

### 3.3 Flutter Widget Tests
- [ ] Test PaymentViewModel state management
- [ ] Test deep link parsing
- [ ] Test UI flow

### 3.4 Manual Testing
- [ ] Test trên Android device thật
- [ ] Test với MoMo app sandbox
- [ ] Test các edge cases

---

## Phase 4: Documentation & Deployment

### 4.1 Documentation
- [ ] Update API documentation
- [ ] Document MoMo setup process
- [ ] Add troubleshooting guide

### 4.2 Deployment Preparation
- [ ] Đăng ký MoMo production credentials
- [ ] Configure production environment variables
- [ ] Set up IPN endpoint với SSL

### 4.3 Monitoring
- [ ] Add logging cho payment transactions
- [ ] Set up alerts cho payment failures
- [ ] Create dashboard cho payment metrics

---

## Dependencies

- Phase 2 depends on Phase 1 completion
- Phase 3 depends on Phase 1 & 2 completion
- Phase 4 can run in parallel with Phase 3

## Implementation Status

**Phase 1: Backend Infrastructure - COMPLETED**
**Phase 2: Flutter Implementation - COMPLETED**
**Phase 3: Testing - PENDING**
**Phase 4: Documentation - PENDING**

## Files Created/Modified

### Backend
- `backend/src/models/Payment.js` - NEW
- `backend/src/services/momoService.js` - NEW
- `backend/src/controllers/paymentController.js` - NEW
- `backend/src/routes/paymentRoutes.js` - NEW
- `backend/src/models/Order.js` - MODIFIED (added payment, paymentStatus fields)
- `backend/src/controllers/orderController.js` - MODIFIED (conditional cart clearing)
- `backend/src/app.js` - MODIFIED (registered payment routes)

### Flutter
- `lib/data/models/payment_model.dart` - NEW
- `lib/core/services/momo_service.dart` - NEW
- `lib/presentation/view_models/payment_view_model.dart` - NEW
- `lib/presentation/screens/payment_processing_screen.dart` - NEW
- `lib/core/network/api_service.dart` - MODIFIED (added payment endpoints)
- `lib/presentation/screens/checkout_screen.dart` - MODIFIED (MoMo flow)
- `lib/main.dart` - MODIFIED (PaymentViewModel provider, deep link handling)
- `pubspec.yaml` - MODIFIED (added url_launcher, app_links)
- `android/app/src/main/AndroidManifest.xml` - MODIFIED (deep link intent filter)
