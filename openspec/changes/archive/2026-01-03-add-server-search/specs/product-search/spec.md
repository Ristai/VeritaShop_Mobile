# Product Search Capability

## Overview
Cho phép người dùng tìm kiếm sản phẩm bằng từ khóa thông qua server-side search.

## ADDED Requirements

### Requirement: Server-side search với debounce
Hệ thống MUST gọi API search sau khi user ngừng gõ 300ms để tránh gọi API quá nhiều.

#### Scenario: Search sản phẩm với từ khóa hợp lệ
- **Given** người dùng đang ở màn hình danh sách sản phẩm
- **When** người dùng nhập "iPhone" vào search bar và ngừng gõ 300ms
- **Then** hệ thống gọi API `/products/search?q=iPhone`
- **And** hiển thị loading indicator trong search bar
- **And** hiển thị kết quả search khi API trả về

#### Scenario: Search với query quá ngắn
- **Given** người dùng đang ở màn hình danh sách sản phẩm
- **When** người dùng nhập ít hơn 2 ký tự
- **Then** hệ thống không gọi API search
- **And** hiển thị danh sách sản phẩm gốc (theo category đã chọn)

#### Scenario: Debounce khi gõ liên tục
- **Given** người dùng đang gõ "Samsung Galaxy"
- **When** người dùng gõ từng ký tự liên tục
- **Then** hệ thống chỉ gọi API 1 lần sau khi ngừng gõ 300ms
- **And** không gọi API cho mỗi ký tự

### Requirement: Loading state cho search
Hệ thống MUST hiển thị trạng thái loading khi đang tìm kiếm để user biết hệ thống đang xử lý.

#### Scenario: Hiển thị loading khi search
- **Given** người dùng vừa submit search query
- **When** API đang được gọi
- **Then** hiển thị loading indicator trong search bar
- **And** giữ nguyên kết quả cũ cho đến khi có kết quả mới

### Requirement: Xử lý lỗi search
Hệ thống MUST xử lý gracefully khi search thất bại và cung cấp fallback.

#### Scenario: Network error khi search
- **Given** người dùng search khi không có kết nối mạng
- **When** API call thất bại
- **Then** hiển thị thông báo lỗi "Không thể tìm kiếm. Vui lòng kiểm tra kết nối mạng."
- **And** fallback về local filter với dữ liệu đã có

#### Scenario: Empty search results
- **Given** người dùng search với từ khóa không có kết quả
- **When** API trả về danh sách rỗng
- **Then** hiển thị "Không tìm thấy sản phẩm cho 'từ khóa'"
- **And** hiển thị gợi ý "Thử tìm với từ khóa khác"
