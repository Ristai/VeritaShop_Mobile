# Proposal: Add MoMo Payment Integration

## Summary

Tích hợp thanh toán MoMo vào ứng dụng VeritaShop, cho phép người dùng thanh toán đơn hàng thông qua ví điện tử MoMo - một trong những phương thức thanh toán phổ biến nhất tại Việt Nam.

## Motivation

- MoMo là ví điện tử phổ biến nhất Việt Nam với hơn 40 triệu người dùng
- Hiện tại ứng dụng chỉ hỗ trợ COD (thanh toán khi nhận hàng)
- Phương thức thanh toán MoMo đã được hiển thị trong UI nhưng chưa có implementation
- Thanh toán online giúp tăng tỷ lệ hoàn thành đơn hàng và giảm rủi ro COD

## Current UI State (Checkout Screen)

UI cho MoMo đã có sẵn trong `checkout_screen.dart`:

### Existing Implementation
- **Payment Methods List**: `OrderViewModel.paymentMethods = ['COD', 'MoMo']`
- **Payment Method Section**: Widget `_buildPaymentMethodSection()` hiển thị danh sách phương thức thanh toán
- **MoMo Icon**: `Icons.account_balance_wallet` (màu tím khi selected)
- **MoMo Label**: Hiện tại chỉ hiện "MoMo" (cần cập nhật thành "Ví MoMo")
- **Selection State**: Highlight với `kAccentColor` và check icon khi được chọn

### Current UI Flow
```
┌─────────────────────────────────────┐
│  Phương thức thanh toán             │
├─────────────────────────────────────┤
│  🚚  Thanh toán khi nhận hàng (COD) │  ← Selected by default
├─────────────────────────────────────┤
│  👛  MoMo                           │  ← Cần implementation
└─────────────────────────────────────┘
```

### UI Changes Required

1. **Update MoMo Label**:
   - Từ: `"MoMo"`
   - Thành: `"Ví MoMo"` với subtitle `"Thanh toán qua ứng dụng MoMo"`

2. **Add MoMo Logo** (optional):
   - Thay icon `account_balance_wallet` bằng MoMo logo asset
   - Màu MoMo: `#b0006d` (magenta)

3. **Payment Processing Screen** (new):
   - Hiển thị loading khi đang xử lý thanh toán
   - Hiển thị kết quả (thành công/thất bại)
   - Button retry hoặc quay về

4. **Checkout Button Behavior**:
   - COD: "Đặt hàng" → tạo order ngay
   - MoMo: "Thanh toán với MoMo" → tạo order → mở MoMo app

## Scope

### In Scope
- Backend: API tạo payment request MoMo
- Backend: API xử lý IPN callback từ MoMo (xác nhận thanh toán)
- Backend: API kiểm tra trạng thái thanh toán
- Flutter App: Xử lý flow thanh toán MoMo (deep link / webview)
- Flutter App: Cập nhật UI checkout để xử lý MoMo payment
- Flutter App: Cập nhật label và icon cho MoMo option
- Lưu trữ transaction records trong database

### Out of Scope
- Refund/Hoàn tiền qua MoMo (có thể thêm sau)
- Các phương thức thanh toán khác (ZaloPay, VNPay...)
- Admin dashboard quản lý thanh toán MoMo

## Technical Approach

Sử dụng MoMo Payment Gateway API v2 với flow:
1. **captureWallet** request type để chuyển hướng user đến MoMo app/web
2. User xác nhận thanh toán trên MoMo
3. MoMo gửi IPN callback đến backend để xác nhận
4. App nhận redirect/deep link và cập nhật UI

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| MoMo API không ổn định | User không thanh toán được | Fallback về COD, retry logic |
| IPN không nhận được | Đơn hàng stuck | Query transaction status API |
| Deep link không hoạt động | UX kém trên Android | Hỗ trợ cả webview fallback |
| Bảo mật signature | Thanh toán giả mạo | Validate signature ở backend |

## Success Metrics

- 100% đơn hàng MoMo được xác nhận qua IPN
- Payment flow hoàn thành < 30 giây
- Error rate < 1%

## Dependencies

- MoMo Business account (partnerCode, accessKey, secretKey)
- Public endpoint cho IPN callback
- Android deep link configuration

## Related Specs

- `openspec/specs/payment/spec.md` (new)
- `openspec/specs/order/spec.md` (existing, modified)

## Files to Modify

### Flutter App
| File | Changes |
|------|---------|
| `lib/presentation/screens/checkout_screen.dart` | Update `_getPaymentLabel()`, update `_placeOrder()` logic |
| `lib/presentation/view_models/order_view_model.dart` | Already has MoMo in paymentMethods list |
| `android/app/src/main/AndroidManifest.xml` | Add deep link intent filter |

### Backend
| File | Changes |
|------|---------|
| `backend/src/controllers/paymentController.js` | New file |
| `backend/src/services/momoService.js` | New file |
| `backend/src/models/Payment.js` | New file |
| `backend/src/routes/paymentRoutes.js` | New file |
| `backend/src/controllers/orderController.js` | Handle MoMo payment method |
