# Design: MoMo Payment Integration

## Architecture Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│   Node.js API    │────▶│   MoMo Gateway  │
│   (Android)     │◀────│   (Backend)      │◀────│   API v2        │
└─────────────────┘     └──────────────────┘     └─────────────────┘
        │                        │
        │                        │
        ▼                        ▼
┌─────────────────┐     ┌──────────────────┐
│   MoMo App      │     │   MongoDB        │
│   (Deep Link)   │     │   (Transactions) │
└─────────────────┘     └──────────────────┘
```

## Payment Flow

### Sequence Diagram

```
User          Flutter App         Backend API          MoMo Gateway         MoMo App
  │                │                   │                    │                   │
  │─Select MoMo───▶│                   │                    │                   │
  │                │                   │                    │                   │
  │                │─Create Payment───▶│                    │                   │
  │                │                   │─Create Request────▶│                   │
  │                │                   │◀───payUrl──────────│                   │
  │                │                   │                    │                   │
  │                │◀──payUrl──────────│                    │                   │
  │                │                   │                    │                   │
  │                │─Open Deep Link───────────────────────────────────────────▶│
  │                │                   │                    │                   │
  │◀──────────────────────────Confirm Payment──────────────────────────────────│
  │                │                   │                    │                   │
  │                │                   │◀───IPN Callback────│                   │
  │                │                   │─Verify & Update────▶                   │
  │                │                   │                    │                   │
  │                │◀──Deep Link Return (redirectUrl)───────│                   │
  │                │                   │                    │                   │
  │                │─Query Status─────▶│                    │                   │
  │                │◀──Payment Result──│                    │                   │
  │                │                   │                    │                   │
  │◀──Order Success│                   │                    │                   │
```

## Backend Components

### 1. MoMo Service (`backend/src/services/momoService.js`)

Encapsulates all MoMo API interactions:

```javascript
// Core methods
- createPayment(orderId, amount, orderInfo, extraData)
- verifySignature(requestBody)
- queryTransactionStatus(orderId, requestId)
- generateSignature(rawSignature, secretKey)
```

### 2. Payment Controller (`backend/src/controllers/paymentController.js`)

New controller for payment operations:

```javascript
// Endpoints
- POST /api/payments/momo/create    // Tạo payment request
- POST /api/payments/momo/ipn       // IPN callback (từ MoMo)
- GET  /api/payments/momo/status/:orderId  // Query status
- GET  /api/payments/:orderId       // Get payment by order
```

### 3. Payment Model (`backend/src/models/Payment.js`)

New model to track payment transactions:

```javascript
{
  order: ObjectId (ref: Order),
  user: ObjectId (ref: User),
  method: String ('momo', 'cod'),
  provider: String ('momo'),

  // MoMo specific
  partnerCode: String,
  requestId: String,
  orderId: String,         // MoMo orderId (unique per transaction)
  transId: Number,         // MoMo transaction ID

  amount: Number,
  status: String ('pending', 'success', 'failed', 'cancelled'),
  resultCode: Number,      // MoMo result code
  message: String,

  // URLs
  payUrl: String,
  deeplink: String,

  // Timestamps
  createdAt: Date,
  paidAt: Date,

  // Raw response storage
  momoResponse: Object,
  ipnData: Object,
}
```

### 4. Order Model Updates

Add payment reference to Order schema:

```javascript
// Add to Order schema
payment: {
  type: Schema.Types.ObjectId,
  ref: 'Payment'
},
paymentStatus: {
  type: String,
  enum: ['pending', 'paid', 'failed'],
  default: 'pending'
}
```

## Flutter Components

### 1. MoMo Service (`lib/core/services/momo_service.dart`)

```dart
class MomoService {
  // Tạo payment request qua backend
  Future<MomoPaymentResponse> createPayment(String orderId, int amount);

  // Kiểm tra trạng thái
  Future<PaymentStatus> checkPaymentStatus(String orderId);

  // Xử lý deep link return
  void handleMomoCallback(Uri uri);
}
```

### 2. Payment ViewModel (`lib/presentation/view_models/payment_view_model.dart`)

```dart
class PaymentViewModel extends ChangeNotifier {
  PaymentStatus _status;
  String? _payUrl;
  String? _errorMessage;

  Future<bool> initiateMomoPayment(String orderId, int amount);
  Future<void> checkPaymentStatus(String orderId);
  void handlePaymentCallback(Uri uri);
}
```

### 3. Deep Link Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="veritashop" android:host="momo-return" />
</intent-filter>
```

### 4. UI Flow Updates

**Checkout Screen** modifications:
- Khi chọn MoMo, tạo order với status `pending_payment`
- Gọi API create MoMo payment
- Nhận `payUrl` và `deeplink`
- Mở MoMo app qua deep link (hoặc WebView fallback)
- Xử lý callback và hiển thị kết quả

## Configuration

### Environment Variables (Backend)

```env
# MoMo Configuration
MOMO_PARTNER_CODE=MOMO_PARTNER_CODE_HERE
MOMO_ACCESS_KEY=YOUR_ACCESS_KEY
MOMO_SECRET_KEY=YOUR_SECRET_KEY
MOMO_ENDPOINT=https://test-payment.momo.vn  # hoặc production URL
MOMO_REDIRECT_URL=veritashop://momo-return
MOMO_IPN_URL=https://your-domain.com/api/payments/momo/ipn
```

### Environment Variables (Flutter)

```env
MOMO_RETURN_SCHEME=veritashop
MOMO_RETURN_HOST=momo-return
```

## Security Considerations

### 1. Signature Validation

Backend MUST validate signature từ MoMo IPN:

```javascript
const rawSignature = `accessKey=${accessKey}&amount=${amount}&extraData=${extraData}&message=${message}&orderId=${orderId}&orderInfo=${orderInfo}&orderType=${orderType}&partnerCode=${partnerCode}&payType=${payType}&requestId=${requestId}&responseTime=${responseTime}&resultCode=${resultCode}&transId=${transId}`;

const expectedSignature = crypto
  .createHmac('sha256', secretKey)
  .update(rawSignature)
  .digest('hex');
```

### 2. Order Validation

- Validate order belongs to authenticated user
- Validate amount matches order total
- Prevent duplicate payments for same order

### 3. IPN Endpoint Security

- Validate request origin (IP whitelist từ MoMo)
- Use HTTPS only
- Respond with correct format để MoMo không retry

## Error Handling

### MoMo Result Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Thành công | Cập nhật order đã thanh toán |
| 9000 | Giao dịch được xác nhận (đang xử lý) | Chờ IPN |
| 1001-1099 | Lỗi user (hủy, không đủ tiền...) | Hiển thị lỗi, cho retry |
| 2001-2099 | Lỗi hệ thống MoMo | Retry hoặc fallback COD |
| 3001-3099 | Lỗi partner | Kiểm tra config |

### Retry Strategy

1. IPN không nhận được sau 5 phút → Query transaction status
2. Query failed → Retry 3 lần với exponential backoff
3. Vẫn failed → Mark order cần xử lý thủ công

## Database Schema

### Payment Collection

```javascript
{
  _id: ObjectId,
  order: ObjectId,
  user: ObjectId,
  method: 'momo',

  // Request data
  requestId: 'MOMO1704367890123',
  momoOrderId: 'MOMO1704367890123',
  amount: 500000,
  orderInfo: 'Thanh toán đơn hàng #ORD-20240104-001',

  // Response data
  payUrl: 'https://test-payment.momo.vn/...',
  deeplink: 'momo://...',

  // Status
  status: 'pending', // pending -> success/failed
  resultCode: null,
  transId: null,

  // Timestamps
  createdAt: ISODate,
  updatedAt: ISODate,
  paidAt: null,

  // Raw data for debugging
  createResponse: {...},
  ipnData: {...}
}
```

## Testing Strategy

### Development Environment
- Sử dụng MoMo sandbox: `test-payment.momo.vn`
- Test credentials từ MoMo developer portal

### Test Cases

1. **Happy path**: User thanh toán thành công
2. **User cancels**: User hủy trên MoMo app
3. **Insufficient balance**: Không đủ tiền trong ví
4. **Network error**: Mất kết nối giữa chừng
5. **IPN delay**: IPN đến trễ, app đã query status
6. **Duplicate IPN**: MoMo gửi IPN 2 lần
7. **Signature mismatch**: Fake IPN attack

## Migration Plan

1. Deploy backend changes (không breaking change)
2. Update Flutter app với feature flag disabled
3. Test end-to-end trên staging
4. Enable feature flag cho internal testing
5. Gradual rollout to users
