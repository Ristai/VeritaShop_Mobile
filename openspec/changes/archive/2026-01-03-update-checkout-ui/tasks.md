## 1. Tạo Price Format Helper
- [x] 1.1 Tạo helper function `formatVND(double price)` trong `lib/core/utils/` để format giá theo chuẩn VN: `200.000 VND`
- [x] 1.2 Export helper từ central location để sử dụng toàn app

## 2. Payment Methods (Checkout)
- [x] 2.1 Cập nhật `paymentMethods` list trong `order_view_model.dart` - chỉ giữ COD và MoMo
- [x] 2.2 Cập nhật `_getPaymentIcon` trong `checkout_screen.dart` - loại bỏ cases cho VNPay, ZaloPay, Card

## 3. Light Mode UI Optimization (Checkout Screen)
- [x] 3.1 Cập nhật `_buildStepIndicator()` - sử dụng `AppColors.of(context)` thay cho hardcoded colors
- [x] 3.2 Cập nhật `_buildAddressSection()` - sử dụng dynamic colors
- [x] 3.3 Cập nhật `_buildPaymentMethodSection()` - sử dụng dynamic colors
- [x] 3.4 Cập nhật `_buildOrderItemsSection()` và `_buildOrderItem()` - sử dụng dynamic colors
- [x] 3.5 Cập nhật `_buildCouponSection()` - sử dụng dynamic colors
- [x] 3.6 Cập nhật `_buildNoteSection()` - sử dụng dynamic colors
- [x] 3.7 Cập nhật `_buildSummarySection()` và `_buildSummaryRow()` - sử dụng dynamic colors
- [x] 3.8 Cập nhật `_buildBottomBar()` - sử dụng dynamic colors
- [x] 3.9 Cập nhật `_showAddressBottomSheet()` - sử dụng dynamic colors
- [x] 3.10 Cập nhật `_showAddAddressDialog()` và `_buildTextField()` - sử dụng dynamic colors

## 4. Price Format - Checkout Screen
- [x] 4.1 Cập nhật `_buildOrderItem()` - line 478: sử dụng format mới
- [x] 4.2 Cập nhật `_buildCouponSection()` - line 538: sử dụng format mới
- [x] 4.3 Cập nhật `_buildSummarySection()` - lines 686-702: sử dụng format mới

## 5. Price Format - Order History Screen
- [x] 5.1 Cập nhật item price display - line 196
- [x] 5.2 Cập nhật order total display - line 237
- [x] 5.3 Cập nhật order detail item price - lines 534, 541
- [x] 5.4 Cập nhật order detail summary - lines 559-567

## 6. Price Format - Order Success Screen
- [x] 6.1 Cập nhật total display - line 69

## 7. Price Format - Admin Screens
- [x] 7.1 Cập nhật `_formatCurrency()` trong `admin_dashboard_screen.dart` - line 29
- [x] 7.2 Cập nhật `_formatCurrency()` trong `admin_reports_screen.dart` - line 30

## 8. Price Format - Models
- [x] 8.1 Cập nhật `formattedPrice` getter trong `product_model.dart` - line 67
- [x] 8.2 Cập nhật `formattedOriginalPrice` getter trong `product_model.dart` - line 78
- [x] 8.3 Cập nhật price format trong `coupon_model.dart` - line 114

## 9. Testing
- [ ] 9.1 Test checkout screen trong light mode
- [ ] 9.2 Test checkout screen trong dark mode
- [ ] 9.3 Verify chỉ còn 2 phương thức thanh toán (COD, MoMo)
- [ ] 9.4 Verify format giá hiển thị đúng chuẩn VN trên tất cả screens
- [ ] 9.5 Test product listing với format giá mới
- [ ] 9.6 Test order history với format giá mới
- [ ] 9.7 Test admin dashboard với format giá mới
