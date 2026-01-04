## ADDED Requirements

### Requirement: Buy Now Direct Checkout
Product Detail Screen MUST cung cấp nút "Mua ngay" (Buy Now) bên cạnh nút "Thêm vào giỏ hàng" để cho phép người dùng đi thẳng đến trang thanh toán mà không cần qua giỏ hàng.

Khi người dùng nhấn nút "Mua ngay":
- Hệ thống MUST chuyển trực tiếp đến trang Checkout với sản phẩm đã chọn
- Số lượng sản phẩm MUST theo giá trị đã chọn trong bộ chọn số lượng
- Giỏ hàng hiện tại MUST KHÔNG bị thay đổi

#### Scenario: User clicks Buy Now button
- **WHEN** user is on Product Detail screen
- **AND** product is in stock
- **AND** user clicks "Mua ngay" button
- **THEN** system navigates to Checkout screen
- **AND** Checkout screen displays only the selected product
- **AND** quantity matches the selected quantity from Product Detail
- **AND** user's cart remains unchanged

#### Scenario: Buy Now button disabled for out of stock
- **WHEN** user is on Product Detail screen
- **AND** product is out of stock (stock = 0)
- **THEN** "Mua ngay" button MUST be disabled
- **AND** button shows visual indication of disabled state

#### Scenario: Buy Now checkout flow completion
- **WHEN** user completes checkout from Buy Now flow
- **THEN** order is placed for the single product
- **AND** user's cart remains unchanged
- **AND** all existing checkout features work (COD, MoMo, PIN verification, coupon)

### Requirement: Checkout Screen Direct Item Support
Checkout Screen MUST hỗ trợ nhận sản phẩm trực tiếp (direct checkout) thông qua tham số `directCheckoutItem` thay vì chỉ từ giỏ hàng.

Khi có `directCheckoutItem`:
- Hiển thị thông tin sản phẩm từ item trực tiếp
- KHÔNG load dữ liệu từ giỏ hàng
- Tất cả tính năng checkout khác (address, payment method, coupon, PIN) MUST hoạt động bình thường

#### Scenario: Checkout with direct item
- **WHEN** CheckoutScreen receives a `directCheckoutItem` parameter
- **THEN** screen displays product info from direct item
- **AND** does not load or display cart items
- **AND** order summary calculates based on direct item

#### Scenario: Checkout without direct item (cart mode)
- **WHEN** CheckoutScreen does not receive `directCheckoutItem` parameter
- **THEN** screen loads and displays items from user's cart
- **AND** existing cart checkout behavior is unchanged
