# Spec: Settings Screen

This spec defines the requirements for the Settings screen in VeritaShop.

## ADDED Requirements

### Requirement: SETTINGS-001 - Settings Screen Layout

The settings screen SHALL display user configuration options organized into logical sections without AI-related features.

#### Scenario: User opens settings screen
- **Given** the user is logged in
- **When** the user navigates to the Settings screen
- **Then** the settings screen SHALL display the following sections:
  - Thông báo (Notifications) - with real-time and sound toggle
  - Giao diện (Theme) - with dark mode toggle and language selector
  - Tài khoản (Account) - with profile, password, and account linking options
  - Dữ liệu & Bảo mật (Data & Security) - with export, cache, and privacy options
  - Hỗ trợ (Support) - with help center and contact options
  - Thông tin (Info) - with version info
- **And** the screen SHALL NOT display any AI & Analytics section
