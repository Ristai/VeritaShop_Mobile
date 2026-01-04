# Change: Add "Buy Now" Button to Product Detail Screen

## Why
Người dùng hiện tại chỉ có thể thêm sản phẩm vào giỏ hàng từ trang chi tiết sản phẩm, sau đó phải vào giỏ hàng rồi mới đến trang checkout. Tính năng "Mua ngay" (Buy Now) cho phép người dùng bỏ qua bước giỏ hàng và đi thẳng đến trang thanh toán với sản phẩm đã chọn, giúp rút ngắn quy trình mua hàng và tăng tỷ lệ chuyển đổi.

## What Changes
- **Thêm nút "Mua ngay"** bên cạnh nút "Thêm vào giỏ hàng" trong bottom bar của Product Detail Screen
- **Mở rộng CheckoutScreen** để hỗ trợ nhận sản phẩm trực tiếp (direct checkout) thay vì chỉ từ giỏ hàng
- **Cập nhật luồng thanh toán** để xử lý cả hai trường hợp: từ giỏ hàng và từ Buy Now

## Impact
- Affected specs: `checkout`
- Affected code:
  - `lib/presentation/screens/product_detail_screen.dart` - Thêm nút Buy Now
  - `lib/presentation/screens/checkout_screen.dart` - Hỗ trợ direct checkout
  - `lib/presentation/view_models/cart_view_model.dart` - Có thể cần thêm phương thức tạo cart summary tạm
