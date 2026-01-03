# Proposal: Add ABSA Sentiment Analysis to Reviews

| Field          | Value                                    |
| -------------- | ---------------------------------------- |
| **Change ID**  | `add-absa-sentiment-analysis`            |
| **Status**     | Draft                                    |
| **Created**    | 2026-01-03                               |

## Why

Product reviews currently use mock data and derive sentiment from star ratings instead of actual text analysis. The UI in `comments_screen.dart` already displays sentiment badges but relies on hardcoded data. Integrating the external ABSA API will provide real aspect-based sentiment analysis.

## What Changes

### Current State
- `comments_screen.dart`: Has sentiment badge UI but uses mock data
- `product_detail_screen.dart`: Uses hardcoded reviews, no sentiment display
- `review_model.dart`: Has sentiment/aiScore/tag fields but derived from rating
- Backend `Review` model: No sentiment fields
- Backend `reviewController`: No ABSA integration

### Backend Changes
1. Add sentiment fields to Review model schema
2. Create ABSA service to call `https://api.honeysocial.click/predict`
3. Call ABSA API in `createReview` and store results
4. Return sentiment data in review API responses

### Flutter Changes
1. Update `review_model.dart` to parse ABSA data with multiple aspects
2. Update `product_detail_screen.dart` to:
   - Fetch real reviews from API
   - Display sentiment badges (reuse pattern from comments_screen)
3. Update `comments_screen.dart` to fetch real data instead of mock

## External API

**Endpoint**: `POST https://api.honeysocial.click/predict`

**Request**: `{ "text": "string" }`

**Response**:
```json
{
  "results": [
    {
      "aspect": "Battery",
      "sentiment": "positive",
      "confidence": 0.92,
      "scores": { "positive": 0.92, "negative": 0.05, "neutral": 0.03 }
    }
  ]
}
```

**Aspects**: Battery, Camera, Performance, Display, Design, Packaging, Price, Shop_Service, Shipping, General

## Scope

### In Scope
- Backend: Add sentiment schema and ABSA integration
- Flutter: Connect product_detail reviews to API
- Flutter: Display aspect-based sentiment badges
- Flutter: Update comments_screen to use real data

### Out of Scope
- Re-analyzing existing reviews
- Admin filtering by sentiment (future enhancement)

## Impact

- **Files Modified**: ~10 files
- **Breaking Changes**: None (additive)
- **External Dependency**: ABSA API at honeysocial.click
