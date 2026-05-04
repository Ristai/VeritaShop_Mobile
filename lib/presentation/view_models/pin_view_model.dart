import 'package:flutter/material.dart';
import '../../core/services/pin_service.dart';

/// ViewModel quản lý trạng thái PIN authentication
/// Sử dụng Provider pattern với ChangeNotifier
/// Hỗ trợ cloud sync và fallback local
class PinViewModel extends ChangeNotifier {
  final _pinService = PinService();

  // State variables
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
  int get remainingAttempts => PinService.maxFailedAttempts - _failedAttempts;

  /// Kiểm tra user cần setup PIN bắt buộc không (user cũ chưa có PIN)
  bool get requiresPinSetup => !_hasCompletedSetup;

  /// Kiểm tra cần hiển thị PIN lock không
  bool get shouldShowPinLock => _isPinEnabled && !_isPinVerified;

  /// Kiểm tra trạng thái PIN khi app khởi động (sync từ cloud)
  Future<void> checkPinStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sync từ cloud và lấy status một lần
      final status = await _pinService.fetchAndSyncPinStatus();

      _isPinEnabled = status['pinEnabled'] ?? false;
      _hasCompletedSetup = status['hasPinSet'] ?? false;
      _isLockedOut = await _pinService.isLockedOut();
      _failedAttempts = await _pinService.getFailedCount();

      if (_isLockedOut) {
        _lockoutRemaining = await _pinService.getLockoutRemaining();
      }

      debugPrint('PinViewModel.checkPinStatus: isPinEnabled=$_isPinEnabled, hasCompletedSetup=$_hasCompletedSetup');
    } catch (e) {
      debugPrint('Error checking PIN status: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Xác thực PIN
  Future<bool> verifyPin(String pin) async {
    if (_isLockedOut) {
      await refreshLockoutStatus();
      if (_isLockedOut) return false;
    }

    try {
      final isValid = await _pinService.verifyPin(pin);

      if (isValid) {
        _isPinVerified = true;
        await _pinService.resetFailedCount();
        _failedAttempts = 0;
        _isLockedOut = false;
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
    } catch (e) {
      debugPrint('Error verifying PIN: $e');
      return false;
    }
  }

  /// Thiết lập PIN mới
  Future<bool> setPin(String pin) async {
    try {
      await _pinService.setPin(pin);
      _isPinEnabled = true;
      _isPinVerified = true;
      _hasCompletedSetup = true;
      _failedAttempts = 0;
      _isLockedOut = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting PIN: $e');
      return false;
    }
  }

  /// Đổi PIN (cần verify PIN cũ trước)
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      final isOldValid = await _pinService.verifyPin(oldPin);
      if (!isOldValid) return false;

      await _pinService.setPin(newPin);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error changing PIN: $e');
      return false;
    }
  }

  /// Bật PIN
  Future<bool> enablePin() async {
    try {
      // Kiểm tra đã có PIN chưa
      final hasPin = await _pinService.hasPinSet();
      if (hasPin) {
        await _pinService.enablePin();
        _isPinEnabled = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error enabling PIN: $e');
      return false;
    }
  }

  /// Tắt PIN
  Future<bool> disablePin() async {
    try {
      await _pinService.disablePin();
      _isPinEnabled = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error disabling PIN: $e');
      return false;
    }
  }

  /// Lock app khi quay lại từ background
  void lockApp() {
    if (_isPinEnabled) {
      _isPinVerified = false;
      notifyListeners();
    }
  }

  /// Unlock app sau khi verify thành công (dùng cho các trường hợp đặc biệt)
  void unlockApp() {
    _isPinVerified = true;
    notifyListeners();
  }

  /// Reset PIN state khi logout (không xóa PIN data - PIN được giữ lại theo device)
  /// Khi login lại, user sẽ cần nhập PIN để xác thực
  void resetPinStateOnLogout() {
    _isPinVerified = false;
    _failedAttempts = 0;
    _isLockedOut = false;
    _lockoutRemaining = Duration.zero;
    // Không reset _isPinEnabled và _hasCompletedSetup vì PIN data vẫn còn trong storage
    notifyListeners();
  }

  /// Xóa hoàn toàn dữ liệu PIN (chỉ dùng khi user muốn xóa PIN hoặc forgot PIN)
  Future<void> clearPinData() async {
    try {
      await _pinService.clearAll();
      _isPinEnabled = false;
      _isPinVerified = false;
      _hasCompletedSetup = false;
      _failedAttempts = 0;
      _isLockedOut = false;
      _lockoutRemaining = Duration.zero;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing PIN data: $e');
    }
  }

  /// Refresh lockout status
  Future<void> refreshLockoutStatus() async {
    try {
      _isLockedOut = await _pinService.isLockedOut();
      if (_isLockedOut) {
        _lockoutRemaining = await _pinService.getLockoutRemaining();
      } else {
        _failedAttempts = await _pinService.getFailedCount();
        _lockoutRemaining = Duration.zero;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing lockout status: $e');
    }
  }

  /// Reset state (không xóa dữ liệu, chỉ reset state trong memory)
  void resetState() {
    _isPinVerified = false;
    _failedAttempts = 0;
    _isLockedOut = false;
    _lockoutRemaining = Duration.zero;
    notifyListeners();
  }
}
