# Design: ABSA Sentiment Analysis Integration

## Architecture Overview

```
┌─────────────┐    ┌──────────────┐    ┌─────────────────────┐
│   Flutter   │───▶│   Backend    │───▶│  ABSA API           │
│   App       │◀───│   (Node.js)  │◀───│  honeysocial.click  │
└─────────────┘    └──────────────┘    └─────────────────────┘
```

## Data Flow

1. User submits review with text
2. Backend receives review data
3. Backend calls ABSA API with review text
4. ABSA API returns sentiment analysis for detected aspects
5. Backend stores review + sentiment in MongoDB
6. Backend returns complete review with sentiment to Flutter
7. Flutter displays aspect-based sentiment badges

## Backend Schema Changes

### Review Model Enhancement

```javascript
// New fields added to Review schema
sentimentAnalysis: [{
  aspect: {
    type: String,
    enum: ['Battery', 'Camera', 'Performance', 'Display', 'Design',
           'Packaging', 'Price', 'Shop_Service', 'Shipping', 'General']
  },
  sentiment: {
    type: String,
    enum: ['positive', 'negative', 'neutral']
  },
  confidence: Number,
  scores: {
    positive: Number,
    negative: Number,
    neutral: Number
  }
}],
overallSentiment: {
  type: String,
  enum: ['positive', 'negative', 'neutral', 'mixed']
}
```

## API Integration Strategy

### Error Handling
- If ABSA API fails: Create review without sentiment (graceful degradation)
- If ABSA API times out (5s): Create review without sentiment
- Log errors but don't block review creation

### Async vs Sync
- **Chosen: Synchronous** - Call ABSA API during createReview
- Reasoning: Immediate feedback to users, simpler implementation
- Trade-off: Slightly slower review submission (~200-500ms)

## Flutter Display Design

### Sentiment Badge Component
```
┌────────────────┐  ┌────────────────┐  ┌────────────────┐
│ 🔋 Pin: Tích   │  │ 📷 Camera:     │  │ 💰 Giá: Tiêu   │
│    cực         │  │    Tích cực    │  │    cực         │
└────────────────┘  └────────────────┘  └────────────────┘
```

### Color Coding
- Positive (Tích cực): Green (#4CAF50)
- Negative (Tiêu cực): Red (#F44336)
- Neutral (Trung tính): Gray/Yellow

## Aspect Translation (Vietnamese)

| Aspect | Vietnamese |
|--------|------------|
| Battery | Pin |
| Camera | Camera |
| Performance | Hiệu năng |
| Display | Màn hình |
| Design | Thiết kế |
| Packaging | Đóng gói |
| Price | Giá |
| Shop_Service | Dịch vụ |
| Shipping | Giao hàng |
| General | Chung |
