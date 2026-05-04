# settings-screen Specification

## Purpose
TBD - created by archiving change remove-ai-analytics-section. Update Purpose after archive.
## Requirements
### Requirement: SETTINGS-001 - Settings Screen Layout

The settings screen SHALL display user configuration options organized into logical sections without AI-related features.

#### Scenario: User opens settings screen
- **Given** the user is logged in
- **When** the user navigates to the Settings screen
- **Then** the settings screen SHALL display the following sections:
  - Thông báo (Notifications) - with real-time and sound toggle
  - Giao diện (Theme) - with dark mode toggle and language selector
  - Bảo mật ứng dụng (App Security) - with PIN lock toggle and change PIN option
  - Tài khoản (Account) - with profile, password, and account linking options
  - Dữ liệu & Bảo mật (Data & Security) - with export, cache, and privacy options
  - Hỗ trợ (Support) - with help center and contact options
  - Thông tin (Info) - with version info
- **And** the screen SHALL NOT display any AI & Analytics section

#### Scenario: User views App Security section
- **WHEN** user views Settings screen
- **THEN** "Bảo mật ứng dụng" section SHALL display:
  - Toggle "Khóa bằng mã PIN" (enable/disable)
  - Option "Đổi mã PIN" (only visible when PIN is enabled)

### Requirement: Cloud PIN Storage
Hệ thống MUST lưu trữ mã PIN của user trên cloud (MongoDB) thay vì chỉ lưu local.

PIN hash MUST được tạo ở client-side bằng SHA-256 trước khi gửi lên server.

User schema MUST có các fields:
- `pinHash` (String, optional) - SHA-256 hash của PIN
- `pinEnabled` (Boolean, default: false) - Trạng thái bật/tắt PIN

#### Scenario: User tạo PIN mới
- **WHEN** user setup PIN mới từ Settings
- **THEN** hệ thống hash PIN bằng SHA-256 ở client
- **AND** gửi `pinHash` lên API `POST /api/users/pin`
- **AND** server lưu `pinHash` và set `pinEnabled = true`

#### Scenario: User xác thực PIN
- **WHEN** user nhập PIN để xác thực
- **THEN** hệ thống hash PIN input bằng SHA-256
- **AND** gửi hash lên API `POST /api/users/pin/verify`
- **AND** server so sánh với `pinHash` đã lưu
- **AND** trả về kết quả valid/invalid

#### Scenario: User bật/tắt PIN
- **WHEN** user toggle PIN setting
- **THEN** hệ thống gọi API `PUT /api/users/pin/toggle`
- **AND** server cập nhật field `pinEnabled`

### Requirement: PIN Cloud Sync on App Start
Khi app khởi động, hệ thống MUST sync trạng thái PIN từ cloud.

#### Scenario: App start với user đã có cloud PIN
- **WHEN** user đã login và có `pinEnabled = true` trên cloud
- **AND** app khởi động
- **THEN** hệ thống fetch PIN status từ cloud
- **AND** hiển thị PIN lock screen nếu cần

#### Scenario: Backward compatibility với local PIN
- **WHEN** user có PIN local nhưng chưa có cloud PIN
- **AND** app khởi động
- **THEN** hệ thống sử dụng local PIN
- **AND** khi user setup PIN mới, sync lên cloud

### Requirement: Change PIN Feature
Settings screen MUST cho phép user đổi mã PIN khi PIN đã được bật.

#### Scenario: User đổi PIN từ Settings
- **WHEN** user có PIN enabled
- **AND** user chọn "Đổi mã PIN" trong Settings
- **THEN** hệ thống yêu cầu nhập PIN cũ để xác thực
- **AND** sau khi xác thực thành công, cho phép nhập PIN mới
- **AND** sync PIN mới lên cloud

