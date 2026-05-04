## 1. Implementation

- [x] 1.1 Cập nhật `checkout_screen.dart` - import PinViewModel
- [x] 1.2 Tạo hàm `_showPinVerificationDialog()` hiển thị bottom sheet nhập PIN
- [x] 1.3 Cập nhật `_placeOrder()` để kiểm tra PIN enabled và gọi verification dialog
- [x] 1.4 Xử lý các trường hợp: PIN đúng → đặt hàng, PIN sai → hiển thị lỗi, Cancel → hủy
- [ ] 1.5 Test flow: User có PIN enabled → nhập đúng → đặt hàng thành công
- [ ] 1.6 Test flow: User có PIN enabled → nhập sai → hiển thị lỗi
- [ ] 1.7 Test flow: User không có PIN → đặt hàng bình thường
