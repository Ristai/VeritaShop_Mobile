---
noteId: "86983862ddb411f0a4cff1c6086bb22a"
tags: []

---

## ADDED Requirements

### Requirement: Create Order
The system SHALL allow creating orders from user's cart.

#### Scenario: Successful order creation
- **WHEN** authenticated user sends `POST /api/orders` with shippingAddress, paymentMethod, and optional note
- **THEN** system creates order with items from user's cart
- **AND** sets order status to "pending"
- **AND** clears user's cart
- **AND** decreases product stock for each item
- **AND** returns created order with order ID

#### Scenario: Empty cart
- **WHEN** user tries to create order with empty cart
- **THEN** system returns 400 error with message "Giỏ hàng trống"

#### Scenario: Missing shipping address
- **WHEN** user creates order without shipping address
- **THEN** system returns 400 error with validation message

#### Scenario: Product out of stock during checkout
- **WHEN** product stock becomes insufficient between add-to-cart and checkout
- **THEN** system returns 400 error with message "Sản phẩm {name} không đủ số lượng"

---

### Requirement: Get Order History
The system SHALL return user's order history.

#### Scenario: User has orders
- **WHEN** authenticated user requests `GET /api/orders`
- **THEN** system returns paginated list of user's orders sorted by createdAt descending
- **AND** each order includes items, status, total, and timestamps

#### Scenario: User has no orders
- **WHEN** user has no order history
- **THEN** system returns empty array

---

### Requirement: Get Order Details
The system SHALL return detailed information for a specific order.

#### Scenario: Order belongs to user
- **WHEN** user requests `GET /api/orders/:id` for their own order
- **THEN** system returns full order details including items with product info, shipping address, payment method

#### Scenario: Order not found or belongs to another user
- **WHEN** user requests order that doesn't exist or belongs to another user
- **THEN** system returns 404 error

---

### Requirement: Cancel Order
The system SHALL allow cancelling pending orders.

#### Scenario: Cancel pending order
- **WHEN** user sends `PUT /api/orders/:id/cancel` for order with status "pending"
- **THEN** system updates order status to "cancelled"
- **AND** restores product stock for each item
- **AND** returns updated order

#### Scenario: Cancel non-pending order
- **WHEN** user tries to cancel order that is not "pending" (e.g., "shipping", "delivered")
- **THEN** system returns 400 error with message "Không thể hủy đơn hàng đã xử lý"

---

### Requirement: Order Status Flow
The system SHALL enforce valid order status transitions.

#### Scenario: Valid status values
- **GIVEN** order statuses: pending, confirmed, processing, shipping, delivered, cancelled
- **THEN** orders follow this flow: pending → confirmed → processing → shipping → delivered
- **AND** cancelled can only be reached from pending

#### Scenario: Status display in Vietnamese
- **WHEN** displaying order status
- **THEN** system maps: pending="Chờ xác nhận", confirmed="Đã xác nhận", processing="Đang xử lý", shipping="Đang giao hàng", delivered="Đã giao hàng", cancelled="Đã hủy"
