# Tasks: Add Voice Search

## 1. Setup & Dependencies
- [x] 1.1 Thêm `record: ^5.1.0` vào pubspec.yaml
- [x] 1.2 Thêm RECORD_AUDIO permission vào AndroidManifest.xml
- [x] 1.3 Thêm NSMicrophoneUsageDescription vào Info.plist (iOS)
- [x] 1.4 Run `flutter pub get`

## 2. Voice Search Service (Backend Logic)
- [x] 2.1 Tạo `lib/core/services/voice_search_service.dart`
- [x] 2.2 Implement `requestPermission()` - kiểm tra và request microphone permission
- [x] 2.3 Implement `startRecording()` - bắt đầu ghi âm với WAV format
- [x] 2.4 Implement `stopRecording()` - dừng ghi âm và trả về file path
- [x] 2.5 Implement `cancelRecording()` - hủy ghi âm và cleanup
- [x] 2.6 Implement `transcribeAudio(filePath)` - gọi API transcribe và trả về text
- [x] 2.7 Xử lý error cases: permission denied, recording failed, API error, timeout

## 3. State Management (ViewModel)
- [x] 3.1 Thêm voice states vào SearchViewModel: `isRecording`, `recordingDuration`, `voiceError`, `isTranscribing`
- [x] 3.2 Implement `startVoiceSearch()` - kiểm tra permission và bắt đầu recording
- [x] 3.3 Implement `stopVoiceSearch()` - stop recording, transcribe, và set search query
- [x] 3.4 Implement `cancelVoiceSearch()` - hủy recording nếu đang record
- [x] 3.5 Thêm Timer để track recording duration (update mỗi giây)
- [x] 3.6 Implement max recording duration (30s) với auto-stop

## 4. UI Integration
- [x] 4.1 Thêm VoiceSearchButton widget vào search bar (product_list_screen.dart)
- [x] 4.2 Implement button states: idle (mic icon), recording (animated pulse), processing (spinner)
- [x] 4.3 Implement tap to start/stop recording (thay đổi từ press-to-talk cho UX tốt hơn)
- [x] 4.4 Hiển thị recording duration khi đang ghi
- [x] 4.5 Show transcribed text trong TextField sau khi hoàn thành
- [x] 4.6 Trigger search với text đã transcribe

## 5. Error Handling & UX
- [x] 5.1 Hiển thị permission rationale dialog trước khi request
- [x] 5.2 Xử lý permission permanently denied - guide user đến Settings
- [x] 5.3 Hiển thị snackbar cho các error cases (network, API, timeout)
- [x] 5.4 Localize tất cả error messages sang tiếng Việt
- [x] 5.5 Cleanup temp audio files sau khi transcribe

## 6. Testing & Validation
- [ ] 6.1 Test permission flow trên Android
- [ ] 6.2 Test permission flow trên iOS
- [ ] 6.3 Test recording và transcription với tiếng Việt
- [ ] 6.4 Test các error scenarios (no network, API error, timeout)
- [ ] 6.5 Test với các từ khóa sản phẩm phổ biến: "iPhone", "Samsung Galaxy", "tai nghe bluetooth"
- [x] 6.6 Run `flutter analyze` để kiểm tra lints
