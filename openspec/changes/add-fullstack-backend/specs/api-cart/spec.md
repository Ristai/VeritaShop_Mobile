---
noteId: "86983861ddb411f0a4cff1c6086bb22a"
tags: []

---

## ADDED Requirements

### Requirement: Get User Cart
The system SHALL return the current user's shopping cart.

#### Scenario: Cart with items
- **WHEN** authenticated user requests `GET /api/cart`
- **THEN** system returns cart with items array containing product details, quantity, and price
- **AND** includes calculated subtotal, shipping fee, tax, and total

#### Scenario: Empty cart
- **WHEN** user has no items in cart
- **THEN** system returns empty items array with totals as 0

---

### Requirement: Add Item to Cart
The system SHALL allow adding products to cart.

#### Scenario: Add new product
- **WHEN** user sends `POST /api/cart` with productId and quantity
- **THEN** system adds item to cart with current product price
- **AND** returns updated cart

#### Scenario: Add existing product
- **WHEN** user adds product that already exists in cart
- **THEN** system increases quantity of existing item
- **AND** returns updated cart

#### Scenario: Product out of stock
- **WHEN** user tries to add product with stock = 0
- **THEN** system returns 400 error with message "Sản phẩm đã hết hàng"

#### Scenario: Quantity exceeds stock
- **WHEN** user tries to add quantity greater than available stock
- **THEN** system returns 400 error with message "Số lượng vượt quá tồn kho"

---

### Requirement: Update Cart Item Quantity
The system SHALL allow updating item quantity in cart.

#### Scenario: Valid quantity update
- **WHEN** user sends `PUT /api/cart/:itemId` with new quantity
- **THEN** system updates quantity and recalculates totals
- **AND** returns updated cart

#### Scenario: Quantity set to 0
- **WHEN** user updates quantity to 0
- **THEN** system removes item from cart

#### Scenario: Invalid item ID
- **WHEN** user tries to update non-existent cart item
- **THEN** system returns 404 error

---

### Requirement: Remove Item from Cart
The system SHALL allow removing items from cart.

#### Scenario: Successful removal
- **WHEN** user sends `DELETE /api/cart/:itemId`
- **THEN** system removes item from cart
- **AND** returns updated cart

---

### Requirement: Clear Cart
The system SHALL allow clearing all items from cart.

#### Scenario: Clear cart
- **WHEN** user sends `DELETE /api/cart`
- **THEN** system removes all items from user's cart
- **AND** returns empty cart

---

### Requirement: Cart Calculations
The system SHALL automatically calculate cart totals.

#### Scenario: Calculate totals
- **GIVEN** cart has items with quantities and prices
- **THEN** subtotal = sum of (price × quantity) for all items
- **AND** shippingFee = 30000 VNĐ if subtotal < 500000, else 0
- **AND** tax = subtotal × 0.1 (10% VAT)
- **AND** total = subtotal + shippingFee + tax
