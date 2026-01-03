# Proposal: Simplify Bottom Navigation

## Change ID
`simplify-bottom-nav`

## Summary
Tái cấu trúc Bottom Navigation Bar với 5 tab chính cho ứng dụng e-commerce: **Trang chủ, Giỏ hàng, Thông báo, Hồ sơ, Cài đặt**.

## Motivation
- Đơn giản hóa giao diện người dùng cho ứng dụng e-commerce
- Tập trung vào các chức năng chính: xem sản phẩm, giỏ hàng, thông báo, hồ sơ và cài đặt
- Loại bỏ các tính năng phân tích/bình luận AI không cần thiết cho người dùng cuối
- Di chuyển tất cả navigation chính xuống bottom bar

## Scope
- **Mobile App Only** - Chỉ ảnh hưởng đến Flutter app
- **Breaking Change** - Xóa bỏ AnalyticsScreen và CommentsScreen khỏi navigation chính

## Key Changes
1. Thay đổi từ 4 tab (Trang chủ AI, Phân tích, Bình luận, Cài đặt) sang 5 tab e-commerce
2. Tab mới: Trang chủ (Sản phẩm), Giỏ hàng, Thông báo, Hồ sơ, Cài đặt
3. Thêm NotificationModel và NotificationViewModel
4. Thêm NotificationsScreen với filter và mock data
5. Cập nhật CartScreen và ProfileScreen với embedded mode
6. Badge hiển thị số lượng trên icon Giỏ hàng và Thông báo

## Out of Scope
- Backend notification API (sử dụng mock data trước)
- Push notifications
- Admin dashboard (giữ nguyên)

## Implementation Status
✅ **Completed**
