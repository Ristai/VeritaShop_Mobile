# Design: Voice Search Integration

## Context
VeritaShop cần tích hợp voice search để cải thiện UX tìm kiếm sản phẩm. API transcribe đã có sẵn tại `https://api3.honeysocial.click/api/transcribe` sử dụng OpenAI Whisper.

### Constraints
- API chỉ hỗ trợ formats: mp3, mp4, mpeg, mpga, m4a, wav, webm
- Max file size: 25MB
- Cần microphone permission trên cả Android và iOS
- Record package phải hỗ trợ output format tương thích

## Goals / Non-Goals

### Goals
- Cho phép user nhấn giữ nút mic để ghi âm voice query
- Tự động gửi audio lên API khi user thả nút
- Hiển thị text kết quả vào search bar và trigger search
- Xử lý graceful các error cases (permission denied, network error, API error)

### Non-Goals
- Wake word detection ("Hey VeritaShop")
- Continuous listening mode
- Offline speech recognition
- Voice response/TTS

## Decisions

### 1. Audio Recording Package
**Decision**: Sử dụng `record` package (^5.1.0)
**Rationale**:
- Hỗ trợ cả Android và iOS
- Output format: AAC/m4a (được API hỗ trợ)
- API đơn giản, maintained tốt
- Alternatives: `flutter_sound` (phức tạp hơn), `audio_recorder` (outdated)

### 2. Recording Format
**Decision**: WAV format
**Rationale**:
- Được API hỗ trợ trực tiếp
- Không cần encode/decode phức tạp
- Quality tốt cho voice recognition
- Tradeoff: File size lớn hơn nhưng với recording ngắn (< 30s) không đáng kể

### 3. Interaction Pattern
**Decision**: Press-and-hold to record
**Rationale**:
- Intuitive cho mobile users
- Giống với pattern của Zalo, Messenger
- Không cần quản lý state phức tạp (start/stop)
- Alternative: Tap to start/stop - dễ gây confuse

### 4. Architecture
**Decision**: Tạo standalone VoiceSearchService + extend SearchViewModel
**Rationale**:
- VoiceSearchService: Singleton, xử lý recording và API call
- SearchViewModel: Thêm voice-related states và methods
- Không tạo VoiceSearchViewModel riêng để tránh state fragmentation
- Reuse toàn bộ search flow hiện tại (history, debounce không cần vì voice là instant)

### 5. API Integration
**Decision**: Tạo method riêng trong VoiceSearchService, không dùng chung ApiService
**Rationale**:
- API transcribe là external service (honeysocial.click), khác với main backend
- Cần multipart/form-data upload
- Không cần auth token
- Giữ ApiService sạch cho internal API

## Component Design

```
┌─────────────────────────────────────────────────────────────┐
│                    ProductListScreen                         │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  SearchBar                                           │    │
│  │  ┌─────────────────────────────┐  ┌──────────────┐  │    │
│  │  │  TextField                  │  │  VoiceButton │  │    │
│  │  └─────────────────────────────┘  └──────────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     SearchViewModel                          │
│  - isRecording: bool                                        │
│  - recordingDuration: Duration                               │
│  - voiceError: String?                                      │
│  + startVoiceSearch()                                       │
│  + stopVoiceSearch() → Future<String?>                      │
│  + cancelVoiceSearch()                                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   VoiceSearchService                         │
│  - _recorder: AudioRecorder                                  │
│  - _isRecording: bool                                       │
│  + requestPermission() → Future<bool>                       │
│  + startRecording() → Future<void>                          │
│  + stopRecording() → Future<String?>   (returns file path)  │
│  + transcribeAudio(filePath) → Future<String>               │
│  + cancelRecording() → Future<void>                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              External API (honeysocial.click)               │
│  POST /api/transcribe                                       │
│  - file: audio blob                                         │
│  - model: gpt-4o-mini-transcribe                            │
│  → { success, text, language }                              │
└─────────────────────────────────────────────────────────────┘
```

## UI States

### VoiceButton States
1. **Idle**: Microphone icon, gray
2. **Recording**: Animated pulse, red, show duration
3. **Processing**: Loading spinner, disabled
4. **Error**: Shake animation, show snackbar

### Recording Overlay (optional enhancement)
- Full-screen semi-transparent overlay
- Animated sound wave visualization
- "Đang nghe..." text
- Swipe up to cancel

## Risks / Trade-offs

### Risk 1: Permission Denied
**Mitigation**:
- Show clear rationale before requesting
- Graceful fallback message: "Vui lòng cấp quyền microphone để sử dụng tìm kiếm bằng giọng nói"
- Deep link to app settings nếu permanently denied

### Risk 2: Network Latency
**Mitigation**:
- Show processing indicator immediately
- Timeout 30s cho API call
- Cache audio file temporarily trong trường hợp retry

### Risk 3: Transcription Accuracy
**Mitigation**:
- Sử dụng prompt parameter với các brand names phổ biến: "iPhone, Samsung, Xiaomi, OPPO, Vivo"
- Show transcribed text trong search bar để user có thể edit trước khi search
- Không auto-submit, đợi user confirm

### Risk 4: Audio File Size
**Mitigation**:
- Limit recording duration: 30 seconds max
- WAV format với sample rate phù hợp (16kHz mono đủ cho speech)
- Clean up temp files sau khi transcribe

## Migration Plan
Không cần migration - đây là feature mới hoàn toàn.

## Open Questions
1. ~~Có cần recording overlay full-screen không?~~ → Không, giữ minimal với button animation
2. ~~Prompt parameter có nên dynamic theo category không?~~ → Phase 2, bắt đầu với static list
