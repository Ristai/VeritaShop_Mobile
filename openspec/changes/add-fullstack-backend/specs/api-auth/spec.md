---
noteId: "86983860ddb411f0a4cff1c6086bb22a"
tags: []

---

## ADDED Requirements

### Requirement: User Registration
The system SHALL allow users to create a new account with name, email, and password.

#### Scenario: Successful registration
- **WHEN** user submits valid registration data (name, email, password)
- **THEN** system creates user account with hashed password
- **AND** returns access token and refresh token
- **AND** stores refresh token in database

#### Scenario: Registration with existing email
- **WHEN** user submits email that already exists
- **THEN** system returns 400 error with message "Email đã được sử dụng"

#### Scenario: Invalid registration data
- **WHEN** user submits invalid data (missing fields, weak password, invalid email format)
- **THEN** system returns 400 error with validation details

---

### Requirement: User Login
The system SHALL authenticate users with email and password.

#### Scenario: Successful login
- **WHEN** user submits valid email and password
- **THEN** system returns access token (expires 7 days) and refresh token (expires 30 days)
- **AND** stores new refresh token in database

#### Scenario: Invalid credentials
- **WHEN** user submits wrong email or password
- **THEN** system returns 401 error with message "Email hoặc mật khẩu không đúng"

---

### Requirement: Token Refresh
The system SHALL allow refreshing access tokens using refresh token.

#### Scenario: Valid refresh token
- **WHEN** client sends valid refresh token
- **THEN** system returns new access token and new refresh token
- **AND** invalidates old refresh token

#### Scenario: Invalid or expired refresh token
- **WHEN** client sends invalid or expired refresh token
- **THEN** system returns 401 error
- **AND** client must re-login

---

### Requirement: User Logout
The system SHALL allow users to logout and invalidate tokens.

#### Scenario: Successful logout
- **WHEN** authenticated user requests logout
- **THEN** system removes refresh token from database
- **AND** returns success response

---

### Requirement: JWT Authentication Middleware
The system SHALL protect routes with JWT authentication.

#### Scenario: Valid access token
- **WHEN** request includes valid Bearer token in Authorization header
- **THEN** system extracts user info and allows request to proceed

#### Scenario: Missing or invalid token
- **WHEN** request has no token or invalid token
- **THEN** system returns 401 Unauthorized error

#### Scenario: Expired access token
- **WHEN** access token is expired
- **THEN** system returns 401 with code "TOKEN_EXPIRED"
- **AND** client should use refresh token to get new access token
