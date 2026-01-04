import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_service.dart';

/// Service xử lý PIN authentication với Cloud sync
/// - Hash PIN với SHA-256 (client-side)
/// - Sync PIN với MongoDB thông qua API
/// - Fallback về local storage nếu network fail
/// - Quản lý lockout sau nhiều lần nhập sai (client-side)
class PinService {
  static final PinService _instance = PinService._internal();
  factory PinService() => _instance;
  PinService._internal();

  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService.instance;

  // Storage keys (local)
  static const _keyPinHash = 'pin_hash';
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyFailedCount = 'pin_failed_count';
  static const _keyLockoutUntil = 'pin_lockout_until';
  static const _keyPinSetupCompleted = 'pin_setup_completed';

  // Constants
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 5);

  /// Hash PIN với SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  /// Lưu PIN mới (sync lên cloud)
  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);

    // Sync lên cloud trước
    try {
      await _apiService.setPin(hash);
    } catch (e) {
      debugPrint('Failed to sync PIN to cloud: $e');
      // Vẫn lưu local nếu cloud fail
    }

    // Lưu local (backup và offline)
    await _storage.write(key: _keyPinHash, value: hash);
    await _storage.write(key: _keyPinEnabled, value: 'true');
    await _storage.write(key: _keyFailedCount, value: '0');
    await _storage.write(key: _keyPinSetupCompleted, value: 'true');
  }

  /// Xác thực PIN (ưu tiên cloud, fallback local)
  Future<bool> verifyPin(String pin) async {
    final inputHash = _hashPin(pin);

    // Thử verify với cloud trước
    try {
      final response = await _apiService.verifyPinCloud(inputHash);
      if (response['success'] == true) {
        final isValid = response['data']?['valid'] == true;
        if (isValid) {
          // Cache PIN hash locally nếu chưa có
          final localHash = await _storage.read(key: _keyPinHash);
          if (localHash == null || localHash != inputHash) {
            await _storage.write(key: _keyPinHash, value: inputHash);
          }
        }
        return isValid;
      }
    } catch (e) {
      debugPrint('Cloud PIN verify failed, falling back to local: $e');
    }

    // Fallback: verify với local PIN
    final storedHash = await _storage.read(key: _keyPinHash);
    if (storedHash == null) return false;
    return storedHash == inputHash;
  }

  /// Kiểm tra PIN đã bật chưa (ưu tiên cloud)
  Future<bool> isPinEnabled() async {
    // Thử lấy từ cloud trước
    try {
      final response = await _apiService.getPinStatus();
      if (response['success'] == true) {
        final enabled = response['data']?['pinEnabled'] == true;
        // Sync local
        await _storage.write(key: _keyPinEnabled, value: enabled ? 'true' : 'false');
        if (response['data']?['hasPinSet'] == true) {
          await _storage.write(key: _keyPinSetupCompleted, value: 'true');
        }
        return enabled;
      }
    } catch (e) {
      debugPrint('Failed to get PIN status from cloud: $e');
    }

    // Fallback local
    final enabled = await _storage.read(key: _keyPinEnabled);
    return enabled == 'true';
  }

  /// Kiểm tra user đã từng setup PIN chưa (cho migration user cũ)
  Future<bool> hasCompletedPinSetup() async {
    // Thử lấy từ cloud trước
    try {
      final response = await _apiService.getPinStatus();
      if (response['success'] == true) {
        final hasPinSet = response['data']?['hasPinSet'] == true;
        if (hasPinSet) {
          await _storage.write(key: _keyPinSetupCompleted, value: 'true');
        }
        return hasPinSet;
      }
    } catch (e) {
      debugPrint('Failed to get PIN status from cloud: $e');
    }

    // Fallback local
    final completed = await _storage.read(key: _keyPinSetupCompleted);
    return completed == 'true';
  }

  /// Đánh dấu đã hoàn thành setup (cho trường hợp user tắt PIN nhưng vẫn đã setup)
  Future<void> markPinSetupCompleted() async {
    await _storage.write(key: _keyPinSetupCompleted, value: 'true');
  }

  /// Bật PIN (sync cloud)
  Future<void> enablePin() async {
    try {
      await _apiService.togglePinCloud(true);
    } catch (e) {
      debugPrint('Failed to enable PIN on cloud: $e');
    }
    await _storage.write(key: _keyPinEnabled, value: 'true');
  }

  /// Tắt PIN (sync cloud)
  Future<void> disablePin() async {
    try {
      await _apiService.togglePinCloud(false);
    } catch (e) {
      debugPrint('Failed to disable PIN on cloud: $e');
    }
    await _storage.write(key: _keyPinEnabled, value: 'false');
  }

  /// Xóa PIN hoàn toàn (sync cloud)
  Future<void> deletePin() async {
    try {
      await _apiService.deletePinCloud();
    } catch (e) {
      debugPrint('Failed to delete PIN on cloud: $e');
    }
    await _storage.delete(key: _keyPinHash);
    await _storage.write(key: _keyPinEnabled, value: 'false');
  }

  /// Xóa tất cả dữ liệu PIN local (khi logout)
  /// Không xóa cloud PIN - PIN được giữ lại theo tài khoản
  Future<void> clearAll() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinEnabled);
    await _storage.delete(key: _keyFailedCount);
    await _storage.delete(key: _keyLockoutUntil);
    await _storage.delete(key: _keyPinSetupCompleted);
  }

  /// Lấy số lần nhập sai
  Future<int> getFailedCount() async {
    final count = await _storage.read(key: _keyFailedCount);
    return int.tryParse(count ?? '0') ?? 0;
  }

  /// Tăng số lần nhập sai và kiểm tra lockout
  Future<void> incrementFailedCount() async {
    final current = await getFailedCount();
    final newCount = current + 1;
    await _storage.write(key: _keyFailedCount, value: '$newCount');

    // Khóa sau maxFailedAttempts lần sai
    if (newCount >= maxFailedAttempts) {
      final lockUntil = DateTime.now().add(lockoutDuration);
      await _storage.write(
        key: _keyLockoutUntil,
        value: lockUntil.toIso8601String(),
      );
    }
  }

  /// Reset số lần nhập sai
  Future<void> resetFailedCount() async {
    await _storage.write(key: _keyFailedCount, value: '0');
    await _storage.delete(key: _keyLockoutUntil);
  }

  /// Kiểm tra có đang bị lockout không
  Future<bool> isLockedOut() async {
    final lockUntilStr = await _storage.read(key: _keyLockoutUntil);
    if (lockUntilStr == null) return false;

    try {
      final lockUntil = DateTime.parse(lockUntilStr);
      if (DateTime.now().isAfter(lockUntil)) {
        // Lockout đã hết hạn, reset
        await resetFailedCount();
        return false;
      }
      return true;
    } catch (e) {
      // Parse error, reset lockout
      await resetFailedCount();
      return false;
    }
  }

  /// Lấy thời gian lockout còn lại
  Future<Duration> getLockoutRemaining() async {
    final lockUntilStr = await _storage.read(key: _keyLockoutUntil);
    if (lockUntilStr == null) return Duration.zero;

    try {
      final lockUntil = DateTime.parse(lockUntilStr);
      final remaining = lockUntil.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Kiểm tra PIN có tồn tại không (để biết có thể verify không)
  Future<bool> hasPinSet() async {
    // Thử cloud trước
    try {
      final response = await _apiService.getPinStatus();
      if (response['success'] == true) {
        return response['data']?['hasPinSet'] == true;
      }
    } catch (e) {
      debugPrint('Failed to check PIN set from cloud: $e');
    }

    // Fallback local
    final hash = await _storage.read(key: _keyPinHash);
    return hash != null && hash.isNotEmpty;
  }

  /// Sync PIN status từ cloud (gọi khi app start)
  Future<void> syncFromCloud() async {
    try {
      final response = await _apiService.getPinStatus();
      if (response['success'] == true) {
        final pinEnabled = response['data']?['pinEnabled'] == true;
        final hasPinSet = response['data']?['hasPinSet'] == true;

        await _storage.write(key: _keyPinEnabled, value: pinEnabled ? 'true' : 'false');
        if (hasPinSet) {
          await _storage.write(key: _keyPinSetupCompleted, value: 'true');
        }
      }
    } catch (e) {
      debugPrint('Failed to sync PIN from cloud: $e');
    }
  }

  /// Fetch PIN status từ cloud và sync, trả về status map
  /// Dùng để tránh gọi API nhiều lần
  Future<Map<String, bool>> fetchAndSyncPinStatus() async {
    // Thử lấy từ cloud trước
    try {
      final response = await _apiService.getPinStatus();
      debugPrint('PinService.fetchAndSyncPinStatus response: $response');

      if (response['success'] == true) {
        final pinEnabled = response['data']?['pinEnabled'] == true;
        final hasPinSet = response['data']?['hasPinSet'] == true;

        // Sync to local storage
        await _storage.write(key: _keyPinEnabled, value: pinEnabled ? 'true' : 'false');
        if (hasPinSet) {
          await _storage.write(key: _keyPinSetupCompleted, value: 'true');
        }

        return {
          'pinEnabled': pinEnabled,
          'hasPinSet': hasPinSet,
        };
      }
    } catch (e) {
      debugPrint('Failed to fetch PIN status from cloud: $e');
    }

    // Fallback to local storage
    final enabled = await _storage.read(key: _keyPinEnabled);
    final completed = await _storage.read(key: _keyPinSetupCompleted);

    return {
      'pinEnabled': enabled == 'true',
      'hasPinSet': completed == 'true',
    };
  }
}
