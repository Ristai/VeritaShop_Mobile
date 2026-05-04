## Context
VeritaShop là ứng dụng e-commerce mobile cần mở rộng khả năng quản trị cho Admin. Hiện tại backend đã có CRUD Products đầy đủ, nhưng User management chỉ có list và toggle status. Cart management cho admin chưa có.

### Stakeholders
- Admin: Cần công cụ mạnh mẽ để quản lý users và hỗ trợ khách hàng
- Users: Hưởng lợi từ việc admin có thể giúp đỡ nhanh chóng (reset password, sửa thông tin)

## Goals / Non-Goals

### Goals
- Admin có thể CRUD đầy đủ User (tạo, xem, sửa, xóa)
- Admin có thể reset mật khẩu cho user
- Admin có thể xem và quản lý giỏ hàng của tất cả users
- Giao diện nhất quán với các màn hình admin hiện có

### Non-Goals
- Không thay đổi logic authentication hiện tại
- Không thêm bulk operations (delete nhiều users cùng lúc)
- Không thêm import/export data

## Decisions

### Decision 1: API Design cho User CRUD
- **What**: Sử dụng RESTful endpoints theo pattern hiện có
- **Why**: Nhất quán với codebase hiện tại (`adminController.js`, `adminRoutes.js`)
- **Alternatives**: GraphQL - không chọn vì project đang dùng REST

### Decision 2: Reset Password Flow
- **What**: Admin reset → tạo temporary password → gửi email cho user
- **Why**: Bảo mật hơn so với hiển thị password trực tiếp
- **Alternatives**:
  - Generate link reset: phức tạp hơn, user cần làm thêm bước
  - Admin set password trực tiếp: rủi ro bảo mật

### Decision 3: Cart Management Scope
- **What**: Admin chỉ có thể xem, sửa số lượng, xóa item - KHÔNG thể thêm item vào cart
- **Why**: Việc thêm item cần user consent và có thể gây confusion về pricing/stock
- **Alternatives**: Full CRUD cart - quá phức tạp và không cần thiết

### Decision 4: UI Pattern
- **What**: Sử dụng Dialog forms như `admin_products_screen.dart`
- **Why**: Nhất quán với UX hiện tại, user đã quen với pattern này

## Risks / Trade-offs

### Risk 1: Security - Admin có quyền lớn
- **Mitigation**: Chỉ admin đã xác thực mới có access, log tất cả actions quan trọng

### Risk 2: Reset password có thể bị lạm dụng
- **Mitigation**: Gửi email thông báo cho user khi password được reset

### Risk 3: Performance khi load tất cả carts
- **Mitigation**: Pagination, chỉ load carts có items

## Migration Plan
- Không cần migration database
- Backend changes deploy trước
- Flutter app update sau
- Rollback: Revert commits, không ảnh hưởng data

## Open Questions
- Không có
