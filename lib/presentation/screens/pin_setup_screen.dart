import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/pin_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/pin_input.dart';
import '../../core/constants/app_colors.dart';

/// Màn hình thiết lập/đổi PIN
/// Hỗ trợ 2 mode:
/// - isRequired = true: Bắt buộc setup cho user cũ, không cho skip
/// - isRequired = false: Setup từ Settings, có thể back
class PinSetupScreen extends StatefulWidget {
  final bool isRequired;
  final bool isChangingPin;

  const PinSetupScreen({
    super.key,
    this.isRequired = false,
    this.isChangingPin = false,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = '';
  bool _isConfirmStep = false;
  bool _showError = false;
  String? _errorMessage;
  bool _isLoading = false;

  // For changing PIN
  bool _isVerifyingOldPin = false;

  @override
  void initState() {
    super.initState();
    if (widget.isChangingPin) {
      _isVerifyingOldPin = true;
    }
  }

  String get _title {
    if (_isVerifyingOldPin) return 'Xác nhận PIN hiện tại';
    if (_isConfirmStep) return 'Xác nhận mã PIN';
    return widget.isChangingPin ? 'Đổi mã PIN' : 'Thiết lập mã PIN';
  }

  String get _subtitle {
    if (_isVerifyingOldPin) return 'Nhập mã PIN hiện tại để tiếp tục';
    if (_isConfirmStep) return 'Nhập lại mã PIN để xác nhận';
    return 'Nhập mã PIN 6 chữ số';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PopScope(
      canPop: !widget.isRequired && !_isLoading,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          title: Text(
            _title,
            style: TextStyle(color: colors.primaryText),
          ),
          leading: _buildBackButton(colors),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _isLoading
              ? _buildLoadingView(colors)
              : Column(
                  children: [
                    // Banner cho user cũ (bắt buộc setup)
                    if (widget.isRequired && !_isConfirmStep && !_isVerifyingOldPin)
                      _buildRequiredBanner(colors),

                    const Spacer(),

                    // Icon
                    _buildIcon(colors),

                    const SizedBox(height: 24),

                    // Title & Subtitle
                    Text(
                      _isVerifyingOldPin
                          ? 'Xác nhận PIN'
                          : (_isConfirmStep ? 'Xác nhận mã PIN' : 'Tạo mã PIN mới'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: colors.secondaryText,
                      ),
                    ),

                    const Spacer(),

                    // PIN Input
                    PinInput(
                      key: ValueKey('$_isConfirmStep-$_isVerifyingOldPin'),
                      pinLength: 6,
                      showError: _showError,
                      errorMessage: _errorMessage,
                      onCompleted: _handlePinCompleted,
                    ),

                    const Spacer(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget? _buildBackButton(AppColors colors) {
    if (widget.isRequired && !_isConfirmStep && !_isVerifyingOldPin) {
      return null; // Không cho back nếu bắt buộc và đang ở bước đầu
    }

    if (_isConfirmStep || _isVerifyingOldPin) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: colors.primaryText),
        onPressed: () {
          setState(() {
            if (_isVerifyingOldPin) {
              Navigator.pop(context);
            } else {
              _isConfirmStep = false;
              _firstPin = '';
              _showError = false;
              _errorMessage = null;
            }
          });
        },
      );
    }

    return IconButton(
      icon: Icon(Icons.arrow_back, color: colors.primaryText),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildIcon(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accent.withOpacity(0.1),
      ),
      child: Icon(
        _isConfirmStep ? Icons.check_circle_outline : Icons.lock_outline,
        size: 56,
        color: colors.accent,
      ),
    );
  }

  Widget _buildRequiredBanner(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bảo mật tài khoản',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Để bảo vệ dữ liệu cá nhân của bạn, '
                  'vui lòng thiết lập mã PIN để tiếp tục sử dụng ứng dụng.',
                  style: TextStyle(
                    color: const Color(0xFF1E40AF).withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.accent),
          const SizedBox(height: 16),
          Text(
            'Đang lưu mã PIN...',
            style: TextStyle(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }

  void _handlePinCompleted(String pin) {
    if (_isVerifyingOldPin) {
      _verifyOldPin(pin);
    } else if (_isConfirmStep) {
      _confirmPin(pin);
    } else {
      _setFirstPin(pin);
    }
  }

  Future<void> _verifyOldPin(String pin) async {
    final pinVM = context.read<PinViewModel>();
    final isValid = await pinVM.verifyPin(pin);

    if (isValid) {
      setState(() {
        _isVerifyingOldPin = false;
        _showError = false;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _showError = true;
        _errorMessage = 'Mã PIN không đúng';
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _showError = false);
        }
      });
    }
  }

  void _setFirstPin(String pin) {
    setState(() {
      _firstPin = pin;
      _isConfirmStep = true;
      _showError = false;
      _errorMessage = null;
    });
  }

  Future<void> _confirmPin(String pin) async {
    if (pin != _firstPin) {
      setState(() {
        _showError = true;
        _errorMessage = 'Mã PIN không khớp. Vui lòng thử lại.';
      });

      Future.delayed(const Duration(milliseconds: 600), () {
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
    setState(() => _isLoading = true);

    final pinVM = context.read<PinViewModel>();
    final success = await pinVM.setPin(pin);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                widget.isChangingPin
                    ? 'Đổi mã PIN thành công!'
                    : 'Thiết lập mã PIN thành công!',
              ),
            ],
          ),
          backgroundColor: kGreenColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Navigate based on context
      if (widget.isRequired) {
        final authVM = context.read<AuthViewModel>();
        if (authVM.user?.role == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        Navigator.of(context).pop(true);
      }
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Không thể lưu mã PIN. Vui lòng thử lại.'),
            ],
          ),
          backgroundColor: kRedColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      setState(() {
        _isConfirmStep = false;
        _firstPin = '';
      });
    }
  }
}
