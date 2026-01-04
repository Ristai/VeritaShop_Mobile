import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/payment_model.dart';
import '../../core/services/momo_service.dart';

/// Payment ViewModel for managing payment state and operations
class PaymentViewModel extends ChangeNotifier {
  final MomoService _momoService = MomoService();

  // State
  bool _isLoading = false;
  String? _errorMessage;
  MomoPaymentResponse? _currentPayment;
  PaymentStatusResponse? _paymentStatus;
  Timer? _statusPollingTimer;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MomoPaymentResponse? get currentPayment => _currentPayment;
  PaymentStatusResponse? get paymentStatus => _paymentStatus;

  // Payment status helpers
  bool get isPaymentSuccess => _paymentStatus?.isPaymentSuccess ?? false;
  bool get isPaymentFailed => _paymentStatus?.isPaymentFailed ?? false;
  bool get isPaymentCancelled => _paymentStatus?.isPaymentCancelled ?? false;
  bool get isPaymentPending => _paymentStatus?.isPaymentPending ?? true;

  /// Initialize MoMo payment for an order
  /// Returns true if payment URL was opened successfully
  Future<bool> initiateMomoPayment(String orderId) async {
    _setLoading(true);
    _clearError();
    _currentPayment = null;
    _paymentStatus = null;

    try {
      // Create payment via API
      final payment = await _momoService.createPayment(orderId);
      _currentPayment = payment;
      notifyListeners();

      // Open MoMo app/web
      final opened = await _momoService.openMomoPayment(payment);

      if (!opened) {
        _setError('Không thể mở ứng dụng MoMo. Vui lòng cài đặt ứng dụng MoMo.');
        return false;
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check payment status for an order
  Future<PaymentStatusResponse?> checkPaymentStatus(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      final status = await _momoService.checkPaymentStatus(orderId);
      _paymentStatus = status;
      notifyListeners();
      return status;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Start polling for payment status
  /// Polls every [intervalSeconds] until payment completes or timeout
  void startStatusPolling(String orderId, {
    int intervalSeconds = 3,
    int timeoutSeconds = 300, // 5 minutes timeout
    VoidCallback? onSuccess,
    VoidCallback? onFailed,
    VoidCallback? onTimeout,
  }) {
    stopStatusPolling();

    int elapsedSeconds = 0;

    _statusPollingTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (timer) async {
        elapsedSeconds += intervalSeconds;

        if (elapsedSeconds >= timeoutSeconds) {
          stopStatusPolling();
          onTimeout?.call();
          return;
        }

        final status = await checkPaymentStatus(orderId);
        if (status == null) return;

        if (status.isPaymentSuccess) {
          stopStatusPolling();
          onSuccess?.call();
        } else if (status.isPaymentFailed || status.isPaymentCancelled) {
          stopStatusPolling();
          onFailed?.call();
        }
      },
    );
  }

  /// Stop polling for payment status
  void stopStatusPolling() {
    _statusPollingTimer?.cancel();
    _statusPollingTimer = null;
  }

  /// Handle MoMo callback from deep link
  Future<void> handleMomoCallback(Uri uri) async {
    final result = _momoService.parseMomoCallback(uri);
    if (result == null) return;

    // Parse extra data to get orderId
    String? orderId = result.orderId;
    if (orderId == null && result.extraData != null) {
      // Try to parse from extraData (base64 encoded JSON)
      try {
        // TODO: Decode extraData if needed
      } catch (_) {}
    }

    // Check payment status from server
    if (orderId != null) {
      await checkPaymentStatus(orderId);
    }
  }

  /// Get result message for display
  String getResultMessage() {
    if (_paymentStatus == null) return '';

    if (isPaymentSuccess) {
      return 'Thanh toán thành công!';
    } else if (isPaymentFailed) {
      return _paymentStatus!.payment.message ?? 'Thanh toán thất bại';
    } else if (isPaymentCancelled) {
      return 'Thanh toán đã bị hủy';
    } else {
      return 'Đang xử lý thanh toán...';
    }
  }

  /// Reset payment state
  void reset() {
    stopStatusPolling();
    _isLoading = false;
    _errorMessage = null;
    _currentPayment = null;
    _paymentStatus = null;
    notifyListeners();
  }

  // Private helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    stopStatusPolling();
    super.dispose();
  }
}
