import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../../data/models/payment_model.dart';
import '../view_models/payment_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../widgets/custom_button.dart';
import 'order_success_screen.dart';
import 'home_screen.dart';

/// Screen for processing MoMo payment
class PaymentProcessingScreen extends StatefulWidget {
  final OrderModel order;

  const PaymentProcessingScreen({
    super.key,
    required this.order,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isInitializing = true;
  bool _paymentInitiated = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  Future<void> _initializePayment() async {
    final paymentViewModel = context.read<PaymentViewModel>();

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    // Initiate MoMo payment
    final success = await paymentViewModel.initiateMomoPayment(widget.order.id);

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _paymentInitiated = success;
        _errorMessage = success ? null : paymentViewModel.errorMessage;
      });

      if (success) {
        // Start polling for payment status
        paymentViewModel.startStatusPolling(
          widget.order.id,
          onSuccess: _onPaymentSuccess,
          onFailed: _onPaymentFailed,
          onTimeout: _onPaymentTimeout,
        );
      }
    }
  }

  void _onPaymentSuccess() {
    if (!mounted) return;

    // Clear cart after successful payment
    context.read<CartViewModel>().clearCart();

    // Navigate to order success screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(order: widget.order),
      ),
    );
  }

  void _onPaymentFailed() {
    if (!mounted) return;

    setState(() {
      _errorMessage = 'Thanh toán thất bại. Vui lòng thử lại.';
    });
  }

  void _onPaymentTimeout() {
    if (!mounted) return;

    setState(() {
      _errorMessage = 'Hết thời gian chờ thanh toán. Vui lòng kiểm tra trạng thái đơn hàng.';
    });
  }

  Future<void> _retryPayment() async {
    await _initializePayment();
  }

  Future<void> _checkStatus() async {
    final paymentViewModel = context.read<PaymentViewModel>();
    final status = await paymentViewModel.checkPaymentStatus(widget.order.id);

    if (status != null && status.isPaymentSuccess) {
      _onPaymentSuccess();
    }
  }

  void _cancelAndGoHome() {
    context.read<PaymentViewModel>().stopStatusPolling();
    context.read<PaymentViewModel>().reset();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    // Don't stop polling here - let it continue if user navigates back
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Thanh toán MoMo', style: TextStyle(color: colors.primaryText)),
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primaryText),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelAndGoHome,
        ),
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, paymentViewModel, _) {
          if (_isInitializing) {
            return _buildLoadingState(colors);
          }

          if (_errorMessage != null) {
            return _buildErrorState(colors);
          }

          if (_paymentInitiated) {
            return _buildWaitingState(colors, paymentViewModel);
          }

          return _buildErrorState(colors);
        },
      ),
    );
  }

  Widget _buildLoadingState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFB0006D).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB0006D)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang khởi tạo thanh toán...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng đợi trong giây lát',
            style: TextStyle(
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState(AppColors colors, PaymentViewModel paymentViewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // MoMo Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFB0006D).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 50,
              color: Color(0xFFB0006D),
            ),
          ),
          const SizedBox(height: 24),

          // Status Text
          Text(
            'Đang chờ thanh toán',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng hoàn tất thanh toán trong ứng dụng MoMo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 32),

          // Order Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow(colors, 'Mã đơn hàng', widget.order.orderNumber),
                const SizedBox(height: 12),
                _buildInfoRow(colors, 'Số tiền', formatVND(widget.order.total),
                    isHighlighted: true),
                const SizedBox(height: 12),
                _buildInfoRow(colors, 'Phương thức', 'Ví MoMo'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Loading indicator
          if (paymentViewModel.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),

          // Status message
          if (paymentViewModel.paymentStatus != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(paymentViewModel.paymentStatus!.payment.status)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(paymentViewModel.paymentStatus!.payment.status),
                    color: _getStatusColor(paymentViewModel.paymentStatus!.payment.status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      paymentViewModel.getResultMessage(),
                      style: TextStyle(
                        color: _getStatusColor(paymentViewModel.paymentStatus!.payment.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),

          // Actions
          CustomButton(
            text: 'Kiểm tra trạng thái',
            onPressed: paymentViewModel.isLoading ? null : _checkStatus,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _cancelAndGoHome,
            child: Text(
              'Quay về trang chủ',
              style: TextStyle(color: colors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kRedColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: kRedColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không thể khởi tạo thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Thử lại',
              onPressed: _retryPayment,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cancelAndGoHome,
              child: Text(
                'Quay về trang chủ',
                style: TextStyle(color: colors.secondaryText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(AppColors colors, String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.secondaryText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? kAccentColor : colors.primaryText,
            fontSize: isHighlighted ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return kGreenColor;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return kRedColor;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return Colors.orange;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return Icons.check_circle;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return Icons.schedule;
      case PaymentStatus.refunded:
        return Icons.replay;
    }
  }
}
