import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/pin_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/pin_input.dart';
import '../../core/constants/app_colors.dart';

/// Màn hình nhập PIN để mở khóa ứng dụng
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  bool _showError = false;
  String? _errorMessage;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _checkLockoutStatus();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _checkLockoutStatus() {
    final pinVM = context.read<PinViewModel>();
    if (pinVM.isLockedOut) {
      _startLockoutTimer();
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final pinVM = context.read<PinViewModel>();
      pinVM.refreshLockoutStatus();

      if (!pinVM.isLockedOut) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PopScope(
      canPop: false, // Không cho back
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.accent.withOpacity(0.1),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 56,
            color: colors.accent,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Nhập mã PIN',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.primaryText,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Nhập mã PIN để mở khóa ứng dụng',
          style: TextStyle(
            fontSize: 15,
            color: colors.secondaryText,
          ),
        ),

        if (pinVM.failedAttempts > 0 && pinVM.remainingAttempts > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Bạn còn ${pinVM.remainingAttempts} lần thử',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.yellow,
                  fontWeight: FontWeight.w500,
                ),
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

        const SizedBox(height: 32),

        TextButton(
          onPressed: _showForgotPinDialog,
          child: Text(
            'Quên mã PIN?',
            style: TextStyle(
              color: colors.accent,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }

  Widget _buildLockoutView(PinViewModel pinVM, AppColors colors) {
    final minutes = pinVM.lockoutRemaining.inMinutes;
    final seconds = pinVM.lockoutRemaining.inSeconds % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.red.withOpacity(0.1),
              ),
              child: Icon(
                Icons.lock_clock,
                size: 80,
                color: colors.red,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Tài khoản đã bị khóa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.primaryText,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Bạn đã nhập sai mã PIN quá nhiều lần',
              style: TextStyle(
                fontSize: 15,
                color: colors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Countdown timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Thử lại sau',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: colors.red,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            TextButton(
              onPressed: _showForgotPinDialog,
              child: Text(
                'Quên mã PIN?',
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPin(String pin, PinViewModel pinVM) async {
    final isValid = await pinVM.verifyPin(pin);

    if (isValid) {
      // Navigate to home
      if (mounted) {
        final authVM = context.read<AuthViewModel>();
        if (authVM.user?.role == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } else {
      setState(() {
        _showError = true;
        _errorMessage = 'Mã PIN không đúng';
      });

      // Check if locked out after this attempt
      if (pinVM.isLockedOut) {
        _startLockoutTimer();
      }

      // Reset error state after animation
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _showError = false);
        }
      });
    }
  }

  void _showForgotPinDialog() {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: colors.accent),
            const SizedBox(width: 12),
            Text(
              'Quên mã PIN?',
              style: TextStyle(color: colors.primaryText),
            ),
          ],
        ),
        content: Text(
          'Bạn cần đăng nhập lại để đặt lại mã PIN.\n\n'
          'Thao tác này sẽ đăng xuất tài khoản của bạn.',
          style: TextStyle(
            color: colors.secondaryText,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(color: colors.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _logout();
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(
                color: colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final pinVM = context.read<PinViewModel>();
    final authVM = context.read<AuthViewModel>();

    // Clear PIN data
    await pinVM.clearPinData();

    // Logout
    await authVM.logout();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
