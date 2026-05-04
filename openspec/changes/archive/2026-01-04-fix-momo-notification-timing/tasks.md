## 1. Implementation

- [x] 1.1 Thêm tham số `paymentMethod` vào hàm `placeOrder()` trong `OrderViewModel`
- [x] 1.2 Cập nhật logic gửi notification trong `placeOrder()` - chỉ gửi khi payment method là COD
- [x] 1.3 Cập nhật `CheckoutScreen` để truyền payment method khi gọi `placeOrder()`
- [x] 1.4 Thêm gọi notification service trong `PaymentProcessingScreen._onPaymentSuccess()` cho MoMo
- [x] 1.5 Thêm logic schedule review reminder trong `_onPaymentSuccess()` cho MoMo

## 2. Testing

- [ ] 2.1 Test đặt hàng COD - notification phải hiện ngay sau khi đặt hàng
- [ ] 2.2 Test đặt hàng MoMo - notification KHÔNG hiện khi chưa thanh toán
- [ ] 2.3 Test đặt hàng MoMo - notification hiện SAU khi thanh toán thành công
- [ ] 2.4 Test review reminder được schedule đúng cho cả 2 phương thức
