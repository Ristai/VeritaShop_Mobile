## ADDED Requirements

### Requirement: Checkout Payment Methods
Trang checkout MUST chỉ hiển thị 2 phương thức thanh toán:
- COD (Thanh toán khi nhận hàng)
- MoMo (Ví điện tử MoMo)

Các phương thức VNPay, ZaloPay, và Card MUST NOT được hiển thị trên giao diện.

#### Scenario: User views payment methods
- **WHEN** user navigates to checkout screen
- **THEN** only COD and MoMo payment options are displayed
- **AND** VNPay, ZaloPay, Card options are not visible

### Requirement: Light Mode UI Compatibility
Tất cả components trong checkout screen MUST sử dụng dynamic colors từ `AppColors.of(context)` để hỗ trợ cả dark mode và light mode.

Các colors MUST KHÔNG được hardcode với dark theme constants (kCardColor, kBackgroundColor, kBorderColor, kPrimaryTextColor, kSecondaryTextColor).

#### Scenario: User views checkout in light mode
- **WHEN** user has enabled light theme
- **AND** user navigates to checkout screen
- **THEN** all components display with light theme colors
- **AND** text is readable with proper contrast
- **AND** borders and backgrounds use light theme palette

#### Scenario: User views checkout in dark mode
- **WHEN** user has enabled dark theme
- **AND** user navigates to checkout screen
- **THEN** all components display with dark theme colors
- **AND** text is readable with proper contrast

### Requirement: Vietnamese Price Format (App-wide)
Tất cả giá tiền trong toàn bộ ứng dụng MUST được format theo chuẩn Việt Nam:
- Sử dụng dấu chấm (.) làm phân cách hàng nghìn
- Hiển thị đơn vị là `VND` thay vì `K đ`
- Ví dụ: `200.000 VND` thay vì `200K đ`

Áp dụng cho tất cả các screens:
- Checkout screen (summary, items, coupon)
- Order history screen (order list, order detail)
- Order success screen
- Admin dashboard
- Admin reports
- Product listing và product detail
- Coupon display

#### Scenario: Product price display
- **WHEN** user views product price anywhere in the app
- **THEN** price is displayed as `XXX.XXX VND` format
- **EXAMPLE** `500000` displays as `500.000 VND`

#### Scenario: Order summary totals display
- **WHEN** user views order summary in checkout or order history
- **THEN** subtotal, shipping fee, tax, discount, and total are displayed in `XXX.XXX VND` format

#### Scenario: Coupon discount display
- **WHEN** user applies a coupon or views applied discount
- **THEN** discount amount is displayed as `-XXX.XXX VND`

#### Scenario: Admin reports and dashboard
- **WHEN** admin views sales reports or dashboard
- **THEN** all monetary values are displayed in `XXX.XXX VND` format

#### Scenario: Product model formatted price
- **WHEN** `formattedPrice` or `formattedOriginalPrice` getters are called
- **THEN** return price string in `XXX.XXX VND` format
