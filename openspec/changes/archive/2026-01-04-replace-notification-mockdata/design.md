## Context
Hệ thống notifications hiện tại sử dụng mock data và chỉ lưu trong memory của Flutter app. Cần chuyển sang kiến trúc có backend storage để đảm bảo notifications được persist và sync giữa các sessions.

**Stakeholders**: End users (customers), Admin, Backend developers, Mobile developers

**Constraints**:
- Phải tương thích với authentication system hiện có (JWT)
- Không làm chậm flow thanh toán/đặt hàng
- Mobile app phải hoạt động khi offline (graceful degradation)

## Goals / Non-Goals

### Goals:
- Lưu trữ notifications trong MongoDB với schema phù hợp
- Cung cấp API để mobile app fetch/update notifications
- Tự động tạo notification khi có events quan trọng (order created, status changed)
- Hỗ trợ filter/pagination cho notification list

### Non-Goals:
- Push notifications (Firebase Cloud Messaging) - out of scope cho change này
- Real-time notifications (WebSocket) - có thể implement sau
- Email notifications - đã có system riêng

## Decisions

### Decision 1: Notification Model Schema
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User, required),
  type: String (enum: ['order', 'promo', 'system']),
  title: String (required),
  message: String (required),
  data: Object (optional - orderId, productId, couponCode, etc.),
  isRead: Boolean (default: false),
  createdAt: Date,
  updatedAt: Date
}
```

**Rationale**:
- Indexed by userId + createdAt cho fast queries
- `data` field flexible cho different notification types
- Matches existing NotificationModel trong Flutter

### Decision 2: API Endpoints
```
GET    /api/notifications        - Get user's notifications (paginated)
POST   /api/notifications        - Create notification (internal/admin use)
PATCH  /api/notifications/:id    - Mark as read
PATCH  /api/notifications/read-all - Mark all as read
DELETE /api/notifications/:id    - Delete single notification
```

**Rationale**: RESTful design consistent với existing API patterns

### Decision 3: Notification Creation Flow
- **Order Created**: Backend tự động tạo notification trong orderController khi order được tạo
- **Order Status Changed**: Khi admin update order status, tạo notification cho user
- **Promo**: Admin có thể tạo promo notifications qua API (bulk hoặc single)

**Rationale**: Backend-driven để đảm bảo consistency và cho phép admin control

### Decision 4: Mobile App Flow
1. App startup: Fetch recent notifications từ API
2. Show notification: Display từ local state (như hiện tại)
3. Mark read: Call API + update local state
4. New order: Backend tạo notification, app refresh list sau khi tạo order

**Alternatives considered**:
- Local storage only: Rejected vì mất data khi uninstall/switch device
- Firebase Realtime DB: Overkill cho use case này, thêm dependency

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|------|--------|------------|
| API latency | Notifications hiển thị chậm | Cache locally, show stale data first |
| Notification spam | User bị overwhelm | Rate limit, batch notifications |
| Data growth | MongoDB size tăng | TTL index xóa old notifications (>30 days) |

## Migration Plan

1. **Phase 1 - Backend**:
   - Thêm Notification model
   - Thêm API endpoints
   - Tích hợp vào orderController

2. **Phase 2 - Frontend**:
   - Thêm NotificationRepository
   - Update NotificationViewModel để fetch từ API
   - Giữ mock data làm fallback khi offline/error

3. **Rollback**: Nếu có issue, frontend có thể switch về mock data bằng feature flag

## Open Questions
- [ ] Có cần notification preferences (user tắt loại notification nào đó)?
- [ ] Retention period cho old notifications? (Đề xuất: 30 ngày)
- [ ] Có cần bulk create API cho admin gửi promo notifications?
