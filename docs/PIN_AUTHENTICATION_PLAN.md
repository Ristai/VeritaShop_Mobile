# Kế hoạch Implement Tính năng Khóa Ứng dụng bằng Mã PIN

## Mục lục
1. [Tổng quan](#1-tổng-quan)
2. [Files cần tạo mới](#2-files-cần-tạo-mới)
3. [Files cần sửa đổi](#3-files-cần-sửa-đổi)
4. [Package cần thêm](#4-package-cần-thêm)
5. [Chi tiết Implementation](#5-chi-tiết-implementation)
6. [Flow Diagram](#6-flow-diagram)
7. [Xử lý User cũ chưa có PIN](#7-xử-lý-user-cũ-chưa-có-pin)
8. [Localization (Tiếng Việt)](#8-localization-tiếng-việt)
9. [Thứ tự thực hiện](#9-thứ-tự-thực-hiện)
10. [Testing Checklist](#10-testing-checklist)

---

## 1. Tổng quan

### Mục đích
Thêm tính năng xác thực bằng mã PIN để bảo vệ dữ liệu cá nhân người dùng trong ứng dụng VeritaShop E-Commerce.

### Yêu cầu chức năng
- PIN 4-6 chữ số
- Hash PIN bằng SHA-256 (bảo mật)
- Lưu trữ an toàn với `flutter_secure_storage`
- Lockout 5 phút sau 5 lần nhập sai
- Yêu cầu PIN khi:
  - Mở ứng dụng (nếu đã bật PIN)
  - Quay lại app từ background sau > 30 giây
- Cho phép bật/tắt PIN trong Settings
- **Bắt buộc** user cũ tạo PIN khi đăng nhập lần đầu sau update

---

## 2. Files cần tạo mới

| File | Mô tả |
|------|-------|
| `lib/core/services/pin_service.dart` | Service xử lý PIN (hash, verify, lưu trữ an toàn) |
| `lib/presentation/view_models/pin_view_model.dart` | State management cho PIN authentication |
| `lib/presentation/screens/pin_lock_screen.dart` | Màn hình nhập PIN khi app bị khóa |
| `lib/presentation/screens/pin_setup_screen.dart` | Màn hình thiết lập/đổi PIN |
| `lib/presentation/widgets/pin_input.dart` | Widget nhập PIN (bàn phím số 0-9) |
| `lib/core/observers/app_lifecycle_observer.dart` | Observer theo dõi app background/foreground |

---

## 3. Files cần sửa đổi

| File | Thay đổi |
|------|----------|
| `pubspec.yaml` | Thêm package `crypto: ^3.0.3` |
| `lib/main.dart` | Thêm PinViewModel provider, lifecycle observer |
| `lib/presentation/screens/settings_screen.dart` | Thêm mục cài đặt PIN |
| `lib/presentation/view_models/auth_view_model.dart` | Xóa PIN data khi logout |
| `lib/core/routes/app_routes.dart` | Thêm routes `/pin-lock`, `/pin-setup` |
| `lib/presentation/screens/splash_screen.dart` | Kiểm tra PIN sau khi auth |

---

## 4. Package cần thêm

```yaml
dependencies:
  crypto: ^3.0.3  # Để hash PIN bằng SHA-256
```

> **Note:** `flutter_secure_storage: ^9.0.0` đã có sẵn trong project.

---

## 5. Chi tiết Implementation

### 5.1. PIN Service

**File:** `lib/core/services/pin_service.dart`

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static final PinService _instance = PinService._internal();
  factory PinService() => _instance;
  PinService._internal();

  final _storage = const FlutterSecureStorage();

  // Storage keys
  static const _keyPinHash = 'pin_hash';
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyFailedCount = 'pin_failed_count';
  static const _keyLockoutUntil = 'pin_lockout_until';
  static const _keyPinSetupCompleted = 'pin_setup_completed';

  // Hash PIN với SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // Lưu PIN mới
  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _storage.write(key: _keyPinHash, value: hash);
    await _storage.write(key: _keyPinEnabled, value: 'true');
    await _storage.write(key: _keyFailedCount, value: '0');
    await _storage.write(key: _keyPinSetupCompleted, value: 'true');
  }

  // Xác thực PIN
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _keyPinHash);
    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  // Kiểm tra PIN đã bật chưa
  Future<bool> isPinEnabled() async {
    final enabled = await _storage.read(key: _keyPinEnabled);
    return enabled == 'true';
  }

  // Kiểm tra user đã từng setup PIN chưa (cho migration)
  Future<bool> hasCompletedPinSetup() async {
    final completed = await _storage.read(key: _keyPinSetupCompleted);
    return completed == 'true';
  }

  // Tắt PIN
  Future<void> disablePin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.write(key: _keyPinEnabled, value: 'false');
  }

  // Xóa tất cả dữ liệu PIN (khi logout)
  Future<void> clearAll() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinEnabled);
    await _storage.delete(key: _keyFailedCount);
    await _storage.delete(key: _keyLockoutUntil);
    await _storage.delete(key: _keyPinSetupCompleted);
  }

  // Quản lý số lần nhập sai
  Future<int> getFailedCount() async {
    final count = await _storage.read(key: _keyFailedCount);
    return int.tryParse(count ?? '0') ?? 0;
  }

  Future<void> incrementFailedCount() async {
    final current = await getFailedCount();
    await _storage.write(key: _keyFailedCount, value: '${current + 1}');

    // Khóa sau 5 lần sai
    if (current + 1 >= 5) {
      final lockUntil = DateTime.now().add(const Duration(minutes: 5));
      await _storage.write(key: _keyLockoutUntil, value: lockUntil.toIso8601String());
    }
  }

  Future<void> resetFailedCount() async {
    await _storage.write(key: _keyFailedCount, value: '0');
    await _storage.delete(key: _keyLockoutUntil);
  }

  Future<bool> isLockedOut() async {
    final lockUntilStr = await _storage.read(key: _keyLockoutUntil);
    if (lockUntilStr == null) return false;

    final lockUntil = DateTime.parse(lockUntilStr);
    if (DateTime.now().isAfter(lockUntil)) {
      await resetFailedCount();
      return false;
    }
    return true;
  }

  Future<Duration> getLockoutRemaining() async {
    final lockUntilStr = await _storage.read(key: _keyLockoutUntil);
    if (lockUntilStr == null) return Duration.zero;

    final lockUntil = DateTime.parse(lockUntilStr);
    return lockUntil.difference(DateTime.now());
  }
}
```

### 5.2. PIN ViewModel

**File:** `lib/presentation/view_models/pin_view_model.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/services/pin_service.dart';

class PinViewModel extends ChangeNotifier {
  final _pinService = PinService();

  bool _isPinEnabled = false;
  bool _isPinVerified = false;
  bool _isLoading = false;
  bool _hasCompletedSetup = false;
  int _failedAttempts = 0;
  bool _isLockedOut = false;
  Duration _lockoutRemaining = Duration.zero;

  // Getters
  bool get isPinEnabled => _isPinEnabled;
  bool get isPinVerified => _isPinVerified;
  bool get isLoading => _isLoading;
  bool get hasCompletedSetup => _hasCompletedSetup;
  int get failedAttempts => _failedAttempts;
  bool get isLockedOut => _isLockedOut;
  Duration get lockoutRemaining => _lockoutRemaining;
  int get remainingAttempts => 5 - _failedAttempts;

  // Kiểm tra trạng thái PIN khi app khởi động
  Future<void> checkPinStatus() async {
    _isLoading = true;
    notifyListeners();

    _isPinEnabled = await _pinService.isPinEnabled();
    _hasCompletedSetup = await _pinService.hasCompletedPinSetup();
    _isLockedOut = await _pinService.isLockedOut();
    _failedAttempts = await _pinService.getFailedCount();

    if (_isLockedOut) {
      _lockoutRemaining = await _pinService.getLockoutRemaining();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Xác thực PIN
  Future<bool> verifyPin(String pin) async {
    if (_isLockedOut) return false;

    final isValid = await _pinService.verifyPin(pin);

    if (isValid) {
      _isPinVerified = true;
      await _pinService.resetFailedCount();
      _failedAttempts = 0;
    } else {
      await _pinService.incrementFailedCount();
      _failedAttempts = await _pinService.getFailedCount();
      _isLockedOut = await _pinService.isLockedOut();

      if (_isLockedOut) {
        _lockoutRemaining = await _pinService.getLockoutRemaining();
      }
    }

    notifyListeners();
    return isValid;
  }

  // Thiết lập PIN mới
  Future<void> setPin(String pin) async {
    await _pinService.setPin(pin);
    _isPinEnabled = true;
    _isPinVerified = true;
    _hasCompletedSetup = true;
    notifyListeners();
  }

  // Đổi PIN (cần verify PIN cũ trước)
  Future<bool> changePin(String oldPin, String newPin) async {
    final isOldValid = await _pinService.verifyPin(oldPin);
    if (!isOldValid) return false;

    await _pinService.setPin(newPin);
    notifyListeners();
    return true;
  }

  // Tắt PIN
  Future<void> disablePin() async {
    await _pinService.disablePin();
    _isPinEnabled = false;
    notifyListeners();
  }

  // Reset khi quay lại từ background
  void lockApp() {
    if (_isPinEnabled) {
      _isPinVerified = false;
      notifyListeners();
    }
  }

  // Xóa dữ liệu PIN (khi logout)
  Future<void> clearPinData() async {
    await _pinService.clearAll();
    _isPinEnabled = false;
    _isPinVerified = false;
    _hasCompletedSetup = false;
    _failedAttempts = 0;
    _isLockedOut = false;
    notifyListeners();
  }

  // Refresh lockout status
  Future<void> refreshLockoutStatus() async {
    _isLockedOut = await _pinService.isLockedOut();
    if (_isLockedOut) {
      _lockoutRemaining = await _pinService.getLockoutRemaining();
    } else {
      _failedAttempts = await _pinService.getFailedCount();
    }
    notifyListeners();
  }
}
```

### 5.3. PIN Input Widget

**File:** `lib/presentation/widgets/pin_input.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PinInput extends StatefulWidget {
  final int pinLength;
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final bool showError;
  final String? errorMessage;

  const PinInput({
    super.key,
    this.pinLength = 6,
    required this.onCompleted,
    this.onChanged,
    this.showError = false,
    this.errorMessage,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> with SingleTickerProviderStateMixin {
  String _pin = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void didUpdateWidget(PinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
        setState(() => _pin = '');
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    if (_pin.length < widget.pinLength) {
      setState(() => _pin += key);
      widget.onChanged?.call(_pin);

      if (_pin.length == widget.pinLength) {
        widget.onCompleted(_pin);
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
      widget.onChanged?.call(_pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        // PIN dots
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.pinLength,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _pin.length
                      ? colors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.showError
                        ? Colors.red
                        : (index < _pin.length ? colors.primary : colors.border),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Error message
        if (widget.showError && widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),

        const SizedBox(height: 40),

        // Numeric keypad
        _buildKeypad(colors),
      ],
    );
  }

  Widget _buildKeypad(AppColors colors) {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3'], colors),
        const SizedBox(height: 16),
        _buildKeypadRow(['4', '5', '6'], colors),
        const SizedBox(height: 16),
        _buildKeypadRow(['7', '8', '9'], colors),
        const SizedBox(height: 16),
        _buildKeypadRow(['', '0', 'backspace'], colors),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys, AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }

        if (key == 'backspace') {
          return _buildKeypadButton(
            onTap: _onBackspace,
            child: Icon(Icons.backspace_outlined, color: colors.textPrimary),
            colors: colors,
          );
        }

        return _buildKeypadButton(
          onTap: () => _onKeyPressed(key),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
          colors: colors,
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({
    required VoidCallback onTap,
    required Widget child,
    required AppColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          border: Border.all(color: colors.border),
        ),
        child: Center(child: child),
      ),
    );
  }
}
```

### 5.4. PIN Lock Screen

**File:** `lib/presentation/screens/pin_lock_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/pin_view_model.dart';
import '../widgets/pin_input.dart';
import '../../core/constants/app_colors.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  bool _showError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return WillPopScope(
      onWillPop: () async => false, // Không cho back
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Consumer<PinViewModel>(
            builder: (context, pinVM, _) {
              if (pinVM.isLockedOut) {
                return _buildLockoutView(pinVM, colors);
              }

              return _buildPinEntryView(pinVM, colors);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPinEntryView(PinViewModel pinVM, AppColors colors) {
    return Column(
      children: [
        const Spacer(),

        // Icon khóa
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withOpacity(0.1),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 48,
            color: colors.primary,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Nhập mã PIN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Nhập mã PIN để mở khóa ứng dụng',
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
          ),
        ),

        if (pinVM.failedAttempts > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Bạn còn ${pinVM.remainingAttempts} lần thử',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
          ),

        const Spacer(),

        PinInput(
          pinLength: 6,
          showError: _showError,
          errorMessage: _errorMessage,
          onCompleted: (pin) => _verifyPin(pin, pinVM),
        ),

        const SizedBox(height: 24),

        TextButton(
          onPressed: _showForgotPinDialog,
          child: Text(
            'Quên mã PIN?',
            style: TextStyle(color: colors.primary),
          ),
        ),

        const Spacer(),
      ],
    );
  }

  Widget _buildLockoutView(PinViewModel pinVM, AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_clock,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Tài khoản đã bị khóa',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng thử lại sau ${pinVM.lockoutRemaining.inMinutes} phút',
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => pinVM.refreshLockoutStatus(),
            child: const Text('Kiểm tra lại'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPin(String pin, PinViewModel pinVM) async {
    final isValid = await pinVM.verifyPin(pin);

    if (isValid) {
      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      setState(() {
        _showError = true;
        _errorMessage = 'Mã PIN không đúng';
      });

      // Reset error state after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _showError = false);
        }
      });
    }
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quên mã PIN?'),
        content: const Text(
          'Bạn cần đăng nhập lại để đặt lại mã PIN. '
          'Thao tác này sẽ đăng xuất tài khoản của bạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // Clear all data and navigate to login
    final pinVM = context.read<PinViewModel>();
    await pinVM.clearPinData();

    // Call auth logout
    // authVM.logout();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
```

### 5.5. PIN Setup Screen

**File:** `lib/presentation/screens/pin_setup_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/pin_view_model.dart';
import '../widgets/pin_input.dart';
import '../../core/constants/app_colors.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isRequired; // true = user cũ, không cho skip

  const PinSetupScreen({
    super.key,
    this.isRequired = false,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = '';
  bool _isConfirmStep = false;
  bool _showError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return WillPopScope(
      onWillPop: () async => !widget.isRequired,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(_isConfirmStep ? 'Xác nhận mã PIN' : 'Thiết lập mã PIN'),
          automaticallyImplyLeading: !widget.isRequired,
          leading: _isConfirmStep
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    _isConfirmStep = false;
                    _firstPin = '';
                  }),
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Banner cho user cũ
              if (widget.isRequired && !_isConfirmStep)
                _buildRequiredBanner(colors),

              const Spacer(),

              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  _isConfirmStep ? Icons.check_circle_outline : Icons.lock_outline,
                  size: 48,
                  color: colors.primary,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _isConfirmStep ? 'Xác nhận mã PIN' : 'Tạo mã PIN mới',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isConfirmStep
                    ? 'Nhập lại mã PIN để xác nhận'
                    : 'Nhập mã PIN 6 chữ số',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),

              const Spacer(),

              PinInput(
                pinLength: 6,
                showError: _showError,
                errorMessage: _errorMessage,
                onCompleted: _isConfirmStep ? _confirmPin : _setFirstPin,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequiredBanner(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.blue.shade700, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bảo mật tài khoản',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Để bảo vệ dữ liệu cá nhân của bạn, '
                  'vui lòng thiết lập mã PIN để tiếp tục sử dụng ứng dụng.',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setFirstPin(String pin) {
    setState(() {
      _firstPin = pin;
      _isConfirmStep = true;
    });
  }

  Future<void> _confirmPin(String pin) async {
    if (pin != _firstPin) {
      setState(() {
        _showError = true;
        _errorMessage = 'Mã PIN không khớp. Vui lòng thử lại.';
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showError = false;
            _isConfirmStep = false;
            _firstPin = '';
          });
        }
      });
      return;
    }

    // Save PIN
    final pinVM = context.read<PinViewModel>();
    await pinVM.setPin(pin);

    // Show success
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thiết lập mã PIN thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate based on context
      if (widget.isRequired) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pop(true);
      }
    }
  }
}
```

### 5.6. App Lifecycle Observer

**File:** `lib/core/observers/app_lifecycle_observer.dart`

```dart
import 'package:flutter/material.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResumedFromBackground;
  final VoidCallback onPaused;

  DateTime? _pausedAt;
  final Duration backgroundThreshold;

  AppLifecycleObserver({
    required this.onResumedFromBackground,
    required this.onPaused,
    this.backgroundThreshold = const Duration(seconds: 30),
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _pausedAt = DateTime.now();
        onPaused();
        break;

      case AppLifecycleState.resumed:
        if (_pausedAt != null) {
          final backgroundDuration = DateTime.now().difference(_pausedAt!);
          if (backgroundDuration >= backgroundThreshold) {
            onResumedFromBackground();
          }
        }
        _pausedAt = null;
        break;

      default:
        break;
    }
  }
}
```

### 5.7. Cập nhật main.dart

```dart
// Thêm import
import 'presentation/view_models/pin_view_model.dart';
import 'core/observers/app_lifecycle_observer.dart';

// Trong MultiProvider, thêm:
ChangeNotifierProvider(create: (_) => PinViewModel()),

// Trong MyApp widget, thêm lifecycle observer:
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AppLifecycleObserver(
      onResumedFromBackground: _onResumedFromBackground,
      onPaused: () {},
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  void _onResumedFromBackground() {
    final pinVM = context.read<PinViewModel>();
    pinVM.lockApp();
    // Navigate to PIN lock if needed
  }

  // ...
}
```

### 5.8. Cập nhật splash_screen.dart

```dart
// Trong _navigateToNextScreen() method:

Future<void> _navigateToNextScreen() async {
  final authViewModel = context.read<AuthViewModel>();
  await authViewModel.checkAuthStatus();

  if (authViewModel.isAuthenticated) {
    final pinVM = context.read<PinViewModel>();
    await pinVM.checkPinStatus();

    // Trường hợp 1: User chưa từng setup PIN (user cũ sau update)
    if (!pinVM.hasCompletedSetup) {
      Navigator.of(context).pushReplacementNamed(
        '/pin-setup',
        arguments: {'isRequired': true},
      );
      return;
    }

    // Trường hợp 2: User đã có PIN và đang bật, cần xác thực
    if (pinVM.isPinEnabled && !pinVM.isPinVerified) {
      Navigator.of(context).pushReplacementNamed('/pin-lock');
      return;
    }

    // Trường hợp 3: User đã xác thực hoặc đã tắt PIN
    _navigateToHome(authViewModel);
  } else {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }
}
```

### 5.9. Cập nhật settings_screen.dart

```dart
// Thêm section Bảo mật:

Widget _buildSecuritySection() {
  return Consumer<PinViewModel>(
    builder: (context, pinVM, _) {
      return _buildSection(
        'Bảo mật ứng dụng',
        Icons.security,
        [
          _buildSwitchTile(
            'Khóa bằng mã PIN',
            'Yêu cầu mã PIN khi mở ứng dụng',
            pinVM.isPinEnabled,
            (value) => _togglePinLock(value, pinVM),
          ),
          if (pinVM.isPinEnabled)
            _buildActionTile(
              'Đổi mã PIN',
              'Thay đổi mã PIN hiện tại',
              Icons.chevron_right,
              () => Navigator.pushNamed(context, '/pin-setup'),
            ),
        ],
      );
    },
  );
}

Future<void> _togglePinLock(bool enable, PinViewModel pinVM) async {
  if (enable) {
    // Navigate to setup PIN
    final result = await Navigator.pushNamed(context, '/pin-setup');
    // PIN will be enabled in setup screen
  } else {
    // Show confirm dialog and verify current PIN
    _showDisablePinDialog(pinVM);
  }
}

void _showDisablePinDialog(PinViewModel pinVM) {
  // Show dialog to verify PIN before disabling
  // ...
}
```

### 5.10. Cập nhật app_routes.dart

```dart
// Thêm routes:
static const String pinLock = '/pin-lock';
static const String pinSetup = '/pin-setup';

// Trong routes map:
static Map<String, WidgetBuilder> routes = {
  // ... existing routes
  pinLock: (context) => const PinLockScreen(),
  pinSetup: (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return PinSetupScreen(isRequired: args?['isRequired'] ?? false);
  },
};
```

### 5.11. Cập nhật auth_view_model.dart

```dart
// Trong logout method:
Future<void> logout() async {
  // ... existing logout code

  // Clear PIN data
  final pinService = PinService();
  await pinService.clearAll();

  // ... rest of logout
}
```

---

## 6. Flow Diagram

### 6.1. App Launch Flow

```
                              APP LAUNCH
                                  │
                                  ▼
                          ┌─────────────┐
                          │ SplashScreen│
                          └─────────────┘
                                  │
                    Check Auth Status
                                  │
                   ┌──────────────┴──────────────┐
                   │                             │
              Authenticated               Not Authenticated
                   │                             │
         Check PIN Status                        │
                   │                             │
         ┌────────┴────────┐                     │
         │                 │                     │
   hasCompletedSetup?  Not Setup                 │
         │                 │                     │
    ┌────┴────┐            │                     │
    │         │            │                     │
 Enabled   Disabled        │                     │
    │         │            │                     │
    ▼         ▼            ▼                     ▼
┌────────┐ ┌──────┐ ┌────────────┐        ┌────────────┐
│PIN Lock│ │ Home │ │ PIN Setup  │        │ Onboarding │
│ Screen │ │Screen│ │ (Required) │        │   Screen   │
└────────┘ └──────┘ └────────────┘        └────────────┘
```

### 6.2. PIN Entry Flow

```
┌────────────────┐
│ PinLockScreen  │
└────────────────┘
        │
  Enter PIN (6 digits)
        │
        ▼
┌───────────────┐
│  Verify PIN   │
└───────────────┘
        │
   ┌────┴────┐
   │         │
 Valid    Invalid
   │         │
   ▼         ▼
┌──────┐  ┌──────────────────┐
│ Home │  │  Show Error      │
│Screen│  │  Increment Fails │
└──────┘  └──────────────────┘
                   │
          ┌───────┴───────┐
          │               │
       < 5 fails     >= 5 fails
          │               │
          ▼               ▼
       Try Again    ┌──────────┐
                    │ Lockout  │
                    │(5 phút)  │
                    └──────────┘
```

### 6.3. Background/Foreground Flow

```
┌─────────────────────────────────────────────┐
│           APP LIFECYCLE                      │
└─────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
   App Paused              App Resumed
        │                       │
  Record timestamp      Check background duration
        │                       │
        │               ┌───────┴───────┐
        │               │               │
        │            >= 30s          < 30s
        │               │               │
        │       Check PIN Enabled?   Continue
        │               │
        │       ┌───────┴───────┐
        │       │               │
        │    Enabled        Disabled
        │       │               │
        │       ▼               ▼
        │  ┌──────────┐     Continue
        │  │Show PIN  │
        │  │Lock      │
        │  │Overlay   │
        │  └──────────┘
        │
        ▼
    [Continue]
```

---

## 7. Xử lý User cũ chưa có PIN

### 7.1. Các trường hợp User

| Loại User | Trạng thái | Hành động |
|-----------|------------|-----------|
| **User mới đăng ký** | Chưa có PIN | Bắt buộc tạo PIN sau đăng ký |
| **User cũ (sau update)** | Chưa có PIN | Bắt buộc tạo PIN khi mở app |
| **User đã có PIN (bật)** | Có PIN, enabled | Yêu cầu nhập PIN |
| **User đã tắt PIN** | Có PIN, disabled | Vào thẳng Home |

### 7.2. Flow chi tiết

**User mới đăng ký:**
```
Register → RegisterSuccess → PinSetupScreen (required) → Home
```

**User cũ đăng nhập (chưa có PIN):**
```
Login → LoginSuccess → Check hasCompletedSetup?
                             │
                       NO (user cũ)
                             │
                             ▼
                    PinSetupScreen (required)
                    ┌────────────────────────┐
                    │ Banner thông báo:      │
                    │ "Để bảo vệ dữ liệu..." │
                    │ - Không cho back       │
                    │ - Không cho skip       │
                    └────────────────────────┘
                             │
                             ▼
                          Home
```

---

## 8. Localization (Tiếng Việt)

```dart
// PIN Lock Screen
'Nhập mã PIN'                         // Enter PIN
'Nhập mã PIN để mở khóa ứng dụng'     // Enter PIN to unlock app
'Mã PIN không đúng'                   // Wrong PIN
'Bạn còn [X] lần thử'                 // You have [X] attempts left
'Tài khoản đã bị khóa'                // Account locked
'Vui lòng thử lại sau [X] phút'       // Please try again in [X] minutes
'Quên mã PIN?'                        // Forgot PIN?
'Kiểm tra lại'                        // Check again

// PIN Setup Screen
'Thiết lập mã PIN'                    // Set up PIN
'Tạo mã PIN mới'                      // Create new PIN
'Nhập mã PIN 6 chữ số'                // Enter 6-digit PIN
'Xác nhận mã PIN'                     // Confirm PIN
'Nhập lại mã PIN để xác nhận'         // Re-enter PIN to confirm
'Mã PIN không khớp. Vui lòng thử lại' // PIN does not match
'Thiết lập mã PIN thành công!'        // PIN setup successful!

// Settings
'Bảo mật ứng dụng'                    // App security
'Khóa bằng mã PIN'                    // Lock with PIN
'Yêu cầu mã PIN khi mở ứng dụng'      // Require PIN when opening app
'Đổi mã PIN'                          // Change PIN
'Thay đổi mã PIN hiện tại'            // Change current PIN

// Required Setup Banner
'Bảo mật tài khoản'                   // Account security
'Để bảo vệ dữ liệu cá nhân của bạn, vui lòng thiết lập mã PIN để tiếp tục sử dụng ứng dụng.'

// Forgot PIN Dialog
'Quên mã PIN?'                        // Forgot PIN?
'Bạn cần đăng nhập lại để đặt lại mã PIN. Thao tác này sẽ đăng xuất tài khoản của bạn.'
'Hủy'                                 // Cancel
'Đăng xuất'                           // Logout
```

---

## 9. Thứ tự thực hiện

1. ☐ Thêm package `crypto: ^3.0.3` vào pubspec.yaml
2. ☐ Tạo `lib/core/services/pin_service.dart`
3. ☐ Tạo `lib/presentation/view_models/pin_view_model.dart`
4. ☐ Tạo `lib/presentation/widgets/pin_input.dart`
5. ☐ Tạo `lib/presentation/screens/pin_lock_screen.dart`
6. ☐ Tạo `lib/presentation/screens/pin_setup_screen.dart` (với mode `isRequired`)
7. ☐ Tạo `lib/core/observers/app_lifecycle_observer.dart`
8. ☐ Cập nhật `lib/core/routes/app_routes.dart`
9. ☐ Cập nhật `lib/main.dart`
10. ☐ Cập nhật `lib/presentation/screens/settings_screen.dart`
11. ☐ Cập nhật `lib/presentation/screens/splash_screen.dart`
12. ☐ Cập nhật `lib/presentation/view_models/auth_view_model.dart`
13. ☐ Test tất cả các flow

---

## 10. Testing Checklist

### Functional Tests

- [ ] PIN setup flow (nhập PIN → xác nhận → thành công)
- [ ] PIN setup với PIN không khớp (hiển thị lỗi, reset)
- [ ] PIN verification với PIN đúng
- [ ] PIN verification với PIN sai (hiển thị số lần còn lại)
- [ ] Lockout sau 5 lần sai
- [ ] Lockout hết hạn sau 5 phút
- [ ] PIN lock hiển thị khi quay lại từ background > 30s
- [ ] PIN lock không hiển thị nếu background < 30s
- [ ] User cũ bắt buộc tạo PIN (không cho skip/back)
- [ ] Tắt PIN trong Settings
- [ ] Đổi PIN trong Settings
- [ ] Xóa PIN data khi logout
- [ ] Forgot PIN flow (logout và đặt lại)

### UI Tests

- [ ] Light/Dark theme support
- [ ] Shake animation khi nhập sai PIN
- [ ] Loading states
- [ ] Error messages hiển thị đúng
- [ ] Banner thông báo cho user cũ
- [ ] Responsive trên các kích thước màn hình

### Security Tests

- [ ] PIN được hash (không lưu plaintext)
- [ ] PIN data được lưu trong secure storage
- [ ] Không thể bypass PIN lock screen
- [ ] Lockout không thể bypass

---

## Tác giả

Tài liệu được tạo bởi Claude AI cho dự án VeritaShop E-Commerce.

**Ngày tạo:** 2025-01-04
