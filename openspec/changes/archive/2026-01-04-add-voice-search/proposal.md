# Change: Add Voice Search (Speech-to-Text)

## Why
Người dùng Việt Nam thường gặp khó khăn khi gõ tên sản phẩm dài hoặc phức tạp (ví dụ: "iPhone 15 Pro Max 256GB"). Voice search giúp tìm kiếm nhanh hơn và thuận tiện hơn, đặc biệt khi đang di chuyển hoặc bận tay.

## What Changes
- Thêm nút microphone vào search bar trong Product List Screen
- Tạo VoiceSearchService để xử lý ghi âm và gọi API transcribe
- Tích hợp với API transcribe tại `https://api3.honeysocial.click/api/transcribe`
- Sử dụng model `gpt-4o-mini-transcribe` cho voice search (nhanh, phù hợp)
- Hỗ trợ recording feedback UI (animation, timer)
- Xử lý permissions (microphone) cho Android và iOS
- Lưu voice search queries vào search history

## API Details
- **Endpoint**: `POST https://api3.honeysocial.click/api/transcribe`
- **Format**: multipart/form-data
- **Fields**:
  - `file` (required): Audio file (mp3, mp4, mpeg, mpga, m4a, wav, webm), max 25MB
  - `model`: `gpt-4o-mini-transcribe` (default, fast)
  - `prompt`: Optional hint để cải thiện accuracy (VD: tên brands)
- **Response**: `{ success: true, text: "...", model: "...", language: "vi" }`

## Impact
- **Affected specs**: `product-search`
- **Affected code**:
  - `lib/presentation/screens/product_list_screen.dart` - Thêm voice button
  - `lib/presentation/view_models/search_view_model.dart` - Thêm voice state
  - `lib/core/services/` - Tạo mới voice_search_service.dart
  - `android/app/src/main/AndroidManifest.xml` - RECORD_AUDIO permission
  - `ios/Runner/Info.plist` - Microphone usage description
  - `pubspec.yaml` - Thêm record package

## Out of Scope
- Continuous voice recognition (chỉ hỗ trợ press-to-talk)
- Voice feedback/TTS cho kết quả
- Offline speech recognition
