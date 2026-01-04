import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../network/api_service.dart';
import '../../data/models/payment_model.dart';

/// Service for handling MoMo payments
class MomoService {
  final ApiService _apiService = ApiService.instance;

  /// Create a MoMo payment for an order
  /// Returns MoMo payment response with payment URL and deep link
  Future<MomoPaymentResponse> createPayment(String orderId) async {
    final response = await _apiService.createMomoPayment(orderId);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Không thể tạo thanh toán MoMo');
    }

    return MomoPaymentResponse.fromApiMap(response['data']);
  }

  /// Check payment status for an order
  Future<PaymentStatusResponse> checkPaymentStatus(String orderId) async {
    final response = await _apiService.checkMomoPaymentStatus(orderId);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Không thể kiểm tra trạng thái thanh toán');
    }

    return PaymentStatusResponse.fromApiMap(response['data']);
  }

  /// Get payment details by order ID
  Future<PaymentModel> getPaymentByOrder(String orderId) async {
    final response = await _apiService.getPaymentByOrder(orderId);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Không thể lấy thông tin thanh toán');
    }

    final paymentData = response['data']['payment'] as Map<String, dynamic>? ?? {};
    return PaymentModel.fromApiMap(paymentData);
  }

  /// Open MoMo app via deep link
  /// Falls back to pay URL if deep link fails
  /// On web, always use payUrl (HTTPS)
  Future<bool> openMomoPayment(MomoPaymentResponse payment) async {
    // On Web, always use payUrl (deep links don't work in browser)
    if (kIsWeb) {
      if (payment.payUrl != null && payment.payUrl!.isNotEmpty) {
        try {
          final payUrlUri = Uri.parse(payment.payUrl!);
          final launched = await launchUrl(
            payUrlUri,
            mode: LaunchMode.externalApplication,
          );
          return launched || payment.payUrl!.isNotEmpty;
        } catch (e) {
          print('Pay URL launch failed: $e');
          return payment.payUrl!.isNotEmpty;
        }
      }
      return false;
    }

    // On Mobile, try deep link first (for native MoMo app)
    if (payment.deeplink != null && payment.deeplink!.isNotEmpty) {
      try {
        final deeplinkUri = Uri.parse(payment.deeplink!);
        final launched = await launchUrl(
          deeplinkUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      } catch (e) {
        // Deep link failed, try pay URL
        print('Deep link launch failed: $e');
      }
    }

    // Fall back to pay URL (opens in browser/webview)
    if (payment.payUrl != null && payment.payUrl!.isNotEmpty) {
      try {
        final payUrlUri = Uri.parse(payment.payUrl!);
        final launched = await launchUrl(
          payUrlUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      } catch (e) {
        print('Pay URL launch failed: $e');
      }
    }

    // If we have a payUrl, return true anyway - user can copy/paste if needed
    return payment.payUrl != null && payment.payUrl!.isNotEmpty;
  }

  /// Parse MoMo callback URL
  /// Returns a map with resultCode, orderId, and other parameters
  MomoCallbackResult? parseMomoCallback(Uri uri) {
    // Expected format: veritashop://momo-return?resultCode=0&orderId=...&message=...
    if (uri.scheme != 'veritashop' || uri.host != 'momo-return') {
      return null;
    }

    final params = uri.queryParameters;

    return MomoCallbackResult(
      resultCode: int.tryParse(params['resultCode'] ?? '') ?? -1,
      orderId: params['orderId'],
      message: params['message'],
      transId: params['transId'],
      amount: double.tryParse(params['amount'] ?? ''),
      extraData: params['extraData'],
    );
  }

  /// Check if the result code indicates success
  bool isPaymentSuccess(int resultCode) {
    return resultCode == 0;
  }

  /// Get message for result code
  String getResultMessage(int resultCode) {
    switch (resultCode) {
      case 0:
        return 'Thanh toán thành công';
      case 1001:
        return 'Giao dịch thất bại';
      case 1002:
        return 'Giao dịch bị từ chối';
      case 1003:
        return 'Giao dịch đã bị hủy';
      case 1004:
        return 'Số tiền vượt quá hạn mức';
      case 1005:
        return 'Giao dịch đang xử lý';
      case 1006:
        return 'Giao dịch hết hạn';
      default:
        return 'Có lỗi xảy ra';
    }
  }
}

/// Result from MoMo callback URL parsing
class MomoCallbackResult {
  final int resultCode;
  final String? orderId;
  final String? message;
  final String? transId;
  final double? amount;
  final String? extraData;

  MomoCallbackResult({
    required this.resultCode,
    this.orderId,
    this.message,
    this.transId,
    this.amount,
    this.extraData,
  });

  bool get isSuccess => resultCode == 0;
  bool get isFailed => resultCode != 0 && resultCode != 1005;
  bool get isProcessing => resultCode == 1005;
  bool get isCancelled => resultCode == 1003;
}
