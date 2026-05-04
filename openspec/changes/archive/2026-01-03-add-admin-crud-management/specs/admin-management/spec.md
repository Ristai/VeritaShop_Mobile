## ADDED Requirements

### Requirement: Admin User CRUD
Admin SHALL have full CRUD capabilities for User management including create, read, update, and delete operations.

#### Scenario: Admin creates a new user
- **WHEN** admin fills in user information (name, email, phone, password) and submits
- **THEN** system creates user with role 'customer' and returns the created user data

#### Scenario: Admin updates user information
- **WHEN** admin modifies user fields (name, email, phone, address) and saves
- **THEN** system updates user record and returns updated data

#### Scenario: Admin deletes a user
- **WHEN** admin confirms deletion of a user
- **THEN** system removes user from database
- **AND** user's cart and pending orders are handled appropriately

#### Scenario: Admin cannot delete themselves
- **WHEN** admin attempts to delete their own account
- **THEN** system rejects the request with appropriate error message

### Requirement: Admin Reset User Password
Admin SHALL be able to reset password for any user account.

#### Scenario: Admin resets user password successfully
- **WHEN** admin requests password reset for a user
- **THEN** system generates a temporary password
- **AND** system sends email to user with new temporary password
- **AND** system returns success message to admin

#### Scenario: Reset password for non-existent user
- **WHEN** admin requests reset for invalid user ID
- **THEN** system returns 404 error

### Requirement: Admin Cart Management
Admin SHALL be able to view and manage shopping carts of all users.

#### Scenario: Admin views all carts with items
- **WHEN** admin accesses cart management screen
- **THEN** system displays list of users who have items in cart
- **AND** shows cart summary (total items, total value) for each user

#### Scenario: Admin views specific user's cart
- **WHEN** admin selects a user's cart
- **THEN** system displays all items in that cart with product details, quantity, and price

#### Scenario: Admin updates cart item quantity
- **WHEN** admin changes quantity of an item in user's cart
- **THEN** system updates the quantity
- **AND** recalculates cart totals

#### Scenario: Admin removes item from user's cart
- **WHEN** admin removes an item from user's cart
- **THEN** system removes the item
- **AND** recalculates cart totals

#### Scenario: Admin clears user's entire cart
- **WHEN** admin clears all items from a user's cart
- **THEN** system removes all items from that cart

### Requirement: Admin User Interface Consistency
Admin UI for new features SHALL maintain consistency with existing admin screens.

#### Scenario: User form matches product form pattern
- **WHEN** admin opens user create/edit form
- **THEN** dialog style matches admin_products_screen form layout
- **AND** uses same color scheme and button styles

#### Scenario: Cart management follows table pattern
- **WHEN** admin views cart list
- **THEN** display style matches admin_orders_screen table layout
- **AND** supports search and filtering
