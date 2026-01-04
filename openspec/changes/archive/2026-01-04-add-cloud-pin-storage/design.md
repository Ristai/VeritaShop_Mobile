## Context
Thay đổi này liên quan đến việc migrate PIN storage từ local (FlutterSecureStorage) sang cloud (MongoDB). Cần cân nhắc về security và backward compatibility.

## Goals / Non-Goals

### Goals
- Cho phép user sử dụng cùng PIN trên nhiều thiết bị
- Admin có thể quản lý PIN của users
- User có thể chỉnh sửa PIN từ Settings

### Non-Goals
- Không thay đổi PIN length (vẫn là 6 digits)
- Không thay đổi lockout mechanism (vẫn client-side)
- Không yêu cầu migrate user cũ (PIN mới sẽ override local PIN)

## Decisions

### Decision 1: PIN hash được tạo ở client
- **What**: Client tạo SHA-256 hash trước khi gửi lên server
- **Why**: Server không bao giờ thấy plaintext PIN → secure hơn
- **Alternative**: Hash ở server - nhưng sẽ expose plaintext trong transit (dù có HTTPS)

### Decision 2: Giữ lockout state ở client
- **What**: Số lần nhập sai và lockout time vẫn lưu ở FlutterSecureStorage
- **Why**:
  - Tránh timing attacks (attacker không biết đã sai bao nhiêu lần)
  - Giảm API calls
- **Alternative**: Lưu trên server - nhưng sẽ expose thông tin và tăng latency

### Decision 3: Hybrid approach cho backward compatibility
- **What**: Check cloud PIN trước, fallback local PIN nếu cloud chưa setup
- **Why**: User cũ không bị mất PIN khi update app
- **Migration**: Khi user setup PIN mới, sẽ sync lên cloud

## Data Flow

```
┌─────────────┐    hash(pin)    ┌─────────────┐    pinHash    ┌──────────┐
│   Client    │ ───────────────▶│   API       │ ─────────────▶│  MongoDB │
│  (Flutter)  │                 │  (Express)  │               │  User.   │
│             │◀─────────────── │             │◀───────────── │ pinHash  │
└─────────────┘    result       └─────────────┘    compare    └──────────┘
```

## API Endpoints

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/api/users/pin` | `{ pinHash }` | `{ success, message }` |
| POST | `/api/users/pin/verify` | `{ pinHash }` | `{ success, valid }` |
| PUT | `/api/users/pin/toggle` | `{ enabled }` | `{ success, pinEnabled }` |
| DELETE | `/api/users/pin` | - | `{ success, message }` |

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Network failure khi verify | Fallback to local cached pinHash |
| User cũ có PIN local, chưa có cloud | First cloud call fails → use local |
| Attacker brute-force API | Rate limiting ở server + client lockout |

## Migration Plan

1. Deploy backend changes (new fields, endpoints)
2. Release mobile app với hybrid PinService
3. Users tự động migrate khi setup/change PIN

## Open Questions
- None - straightforward implementation
