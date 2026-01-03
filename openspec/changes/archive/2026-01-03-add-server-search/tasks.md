# Tasks

## Phase 1: Core Implementation

- [x] **1.1** Tạo `SearchViewModel` riêng để quản lý search state
  - Tách search logic ra khỏi ProductListScreen
  - Quản lý: query, results, loading, error states
  - Implement debounce (300ms delay)

- [x] **1.2** Cập nhật `ProductRepository.searchProducts()`
  - Thêm error handling cho API call
  - Support pagination cho search results

- [x] **1.3** Cập nhật `ProductListScreen` để sử dụng server-side search
  - Thay đổi `_handleSearch()` để gọi SearchViewModel
  - Hiển thị loading indicator khi đang search
  - Xử lý empty results và error states

## Phase 2: UX Improvements

- [x] **2.1** Thêm search loading indicator
  - Skeleton loading cho search results
  - Inline loading trong search bar

- [x] **2.2** Cập nhật search history
  - Chỉ lưu history khi user submit (Enter hoặc tap suggestion)
  - Không lưu khi đang typing

## Phase 3: Testing & Validation

- [ ] **3.1** Test manual các scenarios:
  - Search với query ngắn (<2 ký tự)
  - Search với query dài
  - Search không có kết quả
  - Network error handling
  - Rapid typing (debounce test)

- [ ] **3.2** Verify không regression:
  - Category filter vẫn hoạt động
  - Sort vẫn hoạt động
  - Search history vẫn hoạt động

## Dependencies
- Task 1.1 phải hoàn thành trước 1.3
- Task 1.2 có thể song song với 1.1
- Phase 2 sau Phase 1
- Phase 3 sau Phase 2
