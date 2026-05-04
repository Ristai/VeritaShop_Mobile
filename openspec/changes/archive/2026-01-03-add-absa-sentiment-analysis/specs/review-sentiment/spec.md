# Spec: Review Sentiment Analysis

This spec defines requirements for Aspect-Based Sentiment Analysis (ABSA) in product reviews.

## ADDED Requirements

### Requirement: ABSA-001 - Sentiment Analysis on Review Creation

When a user creates a product review, the system SHALL automatically analyze the review text using an external ABSA API and store the sentiment results for each detected aspect.

#### Scenario: User submits a review with sentiment-bearing text
- **Given** the user is logged in
- **And** the user has a delivered order for a product
- **When** the user submits a review with text containing opinions about product aspects
- **Then** the system SHALL call the ABSA API to analyze the text
- **And** the system SHALL store the sentiment analysis results with the review
- **And** each detected aspect SHALL have a sentiment label (positive, negative, or neutral)
- **And** each detected aspect SHALL have confidence scores

#### Scenario: ABSA API is unavailable
- **Given** the ABSA API is unreachable or returns an error
- **When** the user submits a review
- **Then** the system SHALL create the review without sentiment analysis
- **And** the system SHALL NOT block or fail the review creation

### Requirement: ABSA-002 - Display Sentiment Analysis in UI

The application SHALL display sentiment analysis results as visual badges on reviews.

#### Scenario: Review has sentiment analysis data
- **Given** a review contains sentiment analysis results
- **When** the user views the review in the product detail screen
- **Then** the UI SHALL display sentiment badges for each detected aspect
- **And** each badge SHALL show the aspect name in Vietnamese
- **And** each badge SHALL be color-coded by sentiment:
  - Positive: Green
  - Negative: Red
  - Neutral: Gray/Yellow

#### Scenario: Review has no sentiment data
- **Given** a review does not contain sentiment analysis results
- **When** the user views the review
- **Then** the UI SHALL display the review normally without sentiment badges
- **And** the UI SHALL NOT show any error or placeholder for missing sentiment

### Requirement: ABSA-003 - Supported Aspects

The system SHALL support the following product aspects for sentiment analysis:
- Battery (Pin)
- Camera (Camera)
- Performance (Hiệu năng)
- Display (Màn hình)
- Design (Thiết kế)
- Packaging (Đóng gói)
- Price (Giá)
- Shop_Service (Dịch vụ)
- Shipping (Giao hàng)
- General (Chung)

#### Scenario: Review mentions multiple aspects
- **Given** a review mentions "Pin rất tốt nhưng giá hơi cao"
- **When** the sentiment analysis is performed
- **Then** the system SHALL return sentiment for Battery (positive) and Price (negative)
- **And** each aspect SHALL be independently analyzed
