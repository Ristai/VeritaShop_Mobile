# Tasks for add-buy-now-button

## 1. Update Checkout Screen
- [x] 1.1 Thêm tham số optional `directCheckoutItem` vào CheckoutScreen để nhận thông tin sản phẩm mua ngay
- [x] 1.2 Cập nhật logic trong CheckoutScreen để xử lý cả direct checkout và cart checkout
- [x] 1.3 Hiển thị thông tin sản phẩm từ direct checkout item khi không sử dụng giỏ hàng

## 2. Update Product Detail Screen
- [x] 2.1 Thêm trạng thái `_isBuyingNow` để quản lý loading state cho nút Buy Now
- [x] 2.2 Tạo hàm `_buyNow()` để xử lý logic mua ngay
- [x] 2.3 Cập nhật `_buildBottomBar()` để hiển thị 2 nút: "Thêm vào giỏ hàng" và "Mua ngay"
- [x] 2.4 Điều chỉnh layout bottom bar để hiển thị 2 nút cân đối

## 3. Testing & Validation
- [x] 3.1 Kiểm tra luồng Buy Now hoạt động đúng với COD
- [x] 3.2 Kiểm tra luồng Buy Now hoạt động đúng với MoMo
- [x] 3.3 Kiểm tra PIN verification vẫn hoạt động với Buy Now
- [x] 3.4 Đảm bảo giỏ hàng không bị ảnh hưởng khi sử dụng Buy Now
