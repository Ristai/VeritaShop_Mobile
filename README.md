# VeritaShop - Ecommerce Mobile App

Ứng dụng thương mại điện tử được xây dựng bằng Flutter.

## Yêu cầu hệ thống

### Để chạy trên iOS:
- **macOS** (bắt buộc - không thể build iOS app trên Windows/Linux)
- **Xcode** (phiên bản mới nhất từ App Store)
- **CocoaPods** (cài đặt bằng: `sudo gem install cocoapods`)
- **Flutter SDK** (phiên bản 3.8.1 trở lên)

## Cài đặt và chạy trên iOS

### Bước 1: Cài đặt dependencies Flutter
```bash
flutter pub get
```

### Bước 2: Cài đặt CocoaPods dependencies
```bash
cd ios
pod install
cd ..
```

### Bước 3: Kiểm tra thiết bị iOS có sẵn
```bash
flutter devices
```

### Bước 4: Chạy ứng dụng

#### Trên iOS Simulator:
```bash
# Mở iOS Simulator
open -a Simulator

# Chạy ứng dụng
flutter run
```

Hoặc chỉ định simulator cụ thể:
```bash
flutter run -d "iPhone 15 Pro"
```

#### Trên thiết bị iOS thật:

1. **Kết nối iPhone với Mac** qua cáp USB

2. **Trust máy tính** trên iPhone (nếu lần đầu)

3. **Cấu hình Signing & Capabilities trong Xcode:**
   - Mở file `ios/Runner.xcworkspace` trong Xcode
   - Chọn target "Runner" → tab "Signing & Capabilities"
   - Chọn Team (Apple Developer Account của bạn)
   - Xcode sẽ tự động tạo Provisioning Profile

4. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

   Hoặc build và cài đặt:
   ```bash
   flutter build ios
   ```

### Lưu ý quan trọng:

- **Apple Developer Account**: Cần tài khoản Apple Developer (miễn phí hoặc trả phí) để chạy trên thiết bị thật
- **Bundle Identifier**: Đảm bảo Bundle ID trong Xcode là duy nhất
- **Provisioning Profile**: Xcode sẽ tự động tạo khi bạn chọn Team

## Troubleshooting

### Lỗi "No devices found":
- Đảm bảo iPhone đã unlock và trust máy tính
- Kiểm tra cáp USB kết nối tốt
- Chạy `flutter doctor` để kiểm tra cấu hình

### Lỗi CocoaPods:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Lỗi signing:
- Mở Xcode và kiểm tra lại Signing & Capabilities
- Đảm bảo đã đăng nhập Apple ID trong Xcode Preferences

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
