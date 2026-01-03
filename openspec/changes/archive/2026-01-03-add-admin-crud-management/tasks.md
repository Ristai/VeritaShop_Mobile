## 1. Backend - User CRUD APIs
- [x] 1.1 Add `createUser` function in `adminController.js` (create user with hashed password)
- [x] 1.2 Add `updateUser` function in `adminController.js` (update user fields except password)
- [x] 1.3 Add `deleteUser` function in `adminController.js` (with validation: cannot delete self, handle cart cleanup)
- [x] 1.4 Add `resetUserPassword` function in `adminController.js` (generate temp password, send email)
- [x] 1.5 Add routes in `adminRoutes.js`: POST /users, PUT /users/:id, DELETE /users/:id, POST /users/:id/reset-password

## 2. Backend - Cart Management APIs
- [x] 2.1 Add `getAllCarts` function in `adminController.js` (list carts with items, pagination)
- [x] 2.2 Add `getCartByUser` function in `adminController.js` (get specific user's cart details)
- [x] 2.3 Add `updateCartItem` function in `adminController.js` (update quantity)
- [x] 2.4 Add `deleteCartItem` function in `adminController.js` (remove single item)
- [x] 2.5 Add `clearUserCart` function in `adminController.js` (remove all items)
- [x] 2.6 Add routes in `adminRoutes.js`: GET /carts, GET /carts/:userId, PUT /carts/:userId/items/:itemId, DELETE /carts/:userId/items/:itemId, DELETE /carts/:userId

## 3. Flutter - API Service
- [x] 3.1 Add User CRUD API methods in `api_service.dart`: createAdminUser, updateAdminUser, deleteAdminUser, resetAdminUserPassword
- [x] 3.2 Add Cart management API methods in `api_service.dart`: getAdminCarts, getAdminCartByUser, updateAdminCartItem, deleteAdminCartItem, clearAdminUserCart

## 4. Flutter - Repository
- [x] 4.1 Add User CRUD methods in `admin_repository.dart`: createUser, updateUser, deleteUser, resetUserPassword
- [x] 4.2 Add Cart management methods in `admin_repository.dart`: getCarts, getCartByUser, updateCartItem, deleteCartItem, clearUserCart

## 5. Flutter - Admin User Screen Enhancement
- [x] 5.1 Update `admin_user_view_model.dart`: Add createUser, updateUser, deleteUser, resetPassword methods
- [x] 5.2 Update `admin_users_screen.dart`: Add "Thêm user" button in header
- [x] 5.3 Add user form dialog (similar to product form): name, email, phone, password fields
- [x] 5.4 Add edit button and action in user row
- [x] 5.5 Add delete button with confirmation dialog
- [x] 5.6 Add reset password button with confirmation and success notification
- [x] 5.7 Improve UI styling to match admin_products_screen

## 6. Flutter - Admin Cart Screen (New)
- [x] 6.1 Create `admin_cart_view_model.dart` with state management for carts
- [x] 6.2 Create `admin_carts_screen.dart` with carts listing
- [x] 6.3 Add cart detail view showing all items
- [x] 6.4 Add quantity edit functionality
- [x] 6.5 Add remove item functionality
- [x] 6.6 Add clear cart functionality
- [x] 6.7 Add search/filter by user

## 7. Flutter - Navigation & Integration
- [x] 7.1 Register `AdminCartViewModel` in Provider setup (`main.dart`)
- [x] 7.2 Add "Giỏ hàng" menu item in `admin_shell.dart`
- [x] 7.3 Add route for AdminCartsScreen in navigation

## 8. Testing & Validation
- [x] 8.1 Test User CRUD flow: create → edit → reset password → delete
- [x] 8.2 Test Cart management flow: view → edit quantity → remove item → clear cart
- [x] 8.3 Test edge cases: delete self, reset password email delivery
- [x] 8.4 Run `flutter analyze` to check for issues
