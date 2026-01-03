# Tasks: ABSA Sentiment Analysis Integration

## Backend Tasks

### 1. Create ABSA Service utility
- [x] Create `backend/src/utils/absaService.js`
- [x] Implement `analyzeSentiment(text)` function to call external API
- [x] Add timeout handling (5 seconds)
- [x] Add error handling with graceful fallback

### 2. Update Review Model
- [x] Add `sentimentAnalysis` array field to `Review.js`
- [x] Add `overallSentiment` field
- [x] Define aspect enum and sentiment enum

### 3. Update Review Controller
- [x] Import ABSA service in `reviewController.js`
- [x] Call ABSA API in `createReview` function after validation
- [x] Store sentiment results in review document
- [x] Ensure sentiment data is included in getProductReviews response

### 4. Test Backend
- [x] Test review creation with sentiment analysis
- [x] Test fallback when ABSA API unavailable
- [x] Verify sentiment data in API responses

## Flutter Tasks

### 5. Update ReviewModel
- [x] Add `SentimentAnalysisItem` class for individual aspect results
- [x] Add `sentimentAnalysis` list field to `ReviewModel`
- [x] Add `overallSentiment` field
- [x] Update `fromApiMap` to parse sentiment data from API

### 6. Update Product Detail Screen
- [x] Replace hardcoded reviews with actual API call
- [x] Use `ReviewRepository.getProductReviews(productId)`
- [x] Add sentiment badge display to `_buildReviewItemFromModel`
- [x] Reuse sentiment badge pattern from `comments_screen.dart`

### 7. Update Comments Screen (Optional)
- [ ] Replace mock `_reviews` list with API call (deferred - optional)
- [ ] Use `ReviewRepository` to fetch real reviews
- [ ] Update filtering to work with real data

### 8. Create Sentiment Badge Widget (Reusable)
- [x] Create `lib/presentation/widgets/sentiment_badge.dart`
- [x] Accept aspect (English) and sentiment parameters
- [x] Display Vietnamese aspect name
- [x] Color code by sentiment (green/red/yellow)

## Verification

- [x] New review shows sentiment analysis from ABSA API
- [x] Product detail screen shows real reviews with sentiment
- [x] Sentiment badges display correctly (Tích cực/Tiêu cực/Trung tính)
- [x] App handles missing sentiment gracefully
- [x] No breaking changes to existing functionality
