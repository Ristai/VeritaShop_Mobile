# Proposal: Vietnamese UI Localization

## Summary
Chuyển đổi các hardcoded text tiếng Anh trong màn hình giỏ hàng (cart_screen.dart) sang tiếng Việt để đồng bộ với checkout_screen.dart đã được Việt hóa.

## Motivation
- Màn hình checkout đã hoàn toàn bằng tiếng Việt
- Màn hình cart vẫn còn nhiều text tiếng Anh
- Cần đồng bộ ngôn ngữ giữa 2 màn hình liên quan

## Scope

### Cart Screen (`cart_screen.dart`)
| Tiếng Anh | Tiếng Việt |
|-----------|------------|
| My Cart | Giỏ hàng của tôi |
| Remove Item | Xóa sản phẩm |
| Are you sure you want to remove this item from cart? | Bạn có chắc muốn xóa sản phẩm này? |
| Cancel | Hủy |
| Remove | Xóa |
| Clear Cart | Xóa giỏ hàng |
| Are you sure you want to remove all items from cart? | Bạn có chắc muốn xóa tất cả? |
| Clear | Xóa tất cả |
| Cart updated successfully | Cập nhật giỏ hàng thành công |
| Failed to update cart | Cập nhật giỏ hàng thất bại |
| Item removed from cart | Đã xóa sản phẩm |
| Failed to remove item | Xóa sản phẩm thất bại |
| Cart cleared successfully | Đã xóa toàn bộ giỏ hàng |
| Failed to clear cart | Xóa giỏ hàng thất bại |
| Your cart is empty | Giỏ hàng trống |
| Add items to get started | Thêm sản phẩm để bắt đầu |
| Continue Shopping | Tiếp tục mua sắm |
| Subtotal | Tạm tính |
| Shipping | Phí vận chuyển |
| Tax | Thuế |
| Total | Tổng cộng |
| Proceed to Checkout | Tiến hành thanh toán |
| Error loading/updating/removing/clearing cart | Lỗi tải/cập nhật/xóa giỏ hàng |

### Ngoài phạm vi
- Admin screens (giữ nguyên tiếng Anh)
- Login screen
