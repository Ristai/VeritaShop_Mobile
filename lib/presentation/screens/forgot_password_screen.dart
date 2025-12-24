import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService.instance;

  int _currentStep = 0; // 0: email, 1: code, 2: new password
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.forgotPassword(_emailController.text.trim());
      
      if (response['success'] == true) {
        setState(() => _currentStep = 1);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mã xác nhận đã được gửi đến email của bạn'),
              backgroundColor: kGreenColor,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mã xác nhận');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.verifyResetCode(
        _emailController.text.trim(),
        _codeController.text.trim().toUpperCase(),
      );
      
      if (response['success'] == true) {
        setState(() => _currentStep = 2);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.resetPassword(
        _emailController.text.trim(),
        _codeController.text.trim().toUpperCase(),
        _passwordController.text,
      );
      
      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công!'),
            backgroundColor: kGreenColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Quên mật khẩu',
          style: TextStyle(color: colors.primaryText),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStepIndicator(colors),
                const SizedBox(height: 32),
                _buildStepContent(colors),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kRedColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: kRedColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: kRedColor, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(AppColors colors) {
    final steps = ['Email', 'Xác nhận', 'Mật khẩu mới'];
    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index <= _currentStep;
        final isCurrent = index == _currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? kAccentColor : colors.card,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? kAccentColor : colors.border,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: isActive && index < _currentStep
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : colors.secondaryText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? kAccentColor : colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: index < _currentStep ? kAccentColor : colors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(AppColors colors) {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep(colors);
      case 1:
        return _buildCodeStep(colors);
      case 2:
        return _buildPasswordStep(colors);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmailStep(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.email_outlined,
                size: 60,
                color: kAccentColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Nhập email của bạn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chúng tôi sẽ gửi mã xác nhận đến email của bạn',
                style: TextStyle(color: colors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Nhập email đăng ký',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Gửi mã xác nhận',
          onPressed: _isLoading ? null : _sendResetCode,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildCodeStep(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.lock_outline,
                size: 60,
                color: kAccentColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Nhập mã xác nhận',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã xác nhận đã được gửi đến\n${_emailController.text}',
                style: TextStyle(color: colors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _codeController,
          label: 'Mã xác nhận',
          hint: 'Nhập mã 6 ký tự',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Không nhận được mã? ',
              style: TextStyle(color: colors.secondaryText),
            ),
            TextButton(
              onPressed: _isLoading ? null : _sendResetCode,
              child: const Text('Gửi lại', style: TextStyle(color: kAccentColor)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Xác nhận',
          onPressed: _isLoading ? null : _verifyCode,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildPasswordStep(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.password_outlined,
                size: 60,
                color: kAccentColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Tạo mật khẩu mới',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mật khẩu mới phải có ít nhất 6 ký tự',
                style: TextStyle(color: colors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _passwordController,
          label: 'Mật khẩu mới',
          hint: 'Nhập mật khẩu mới',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            if (value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Xác nhận mật khẩu',
          hint: 'Nhập lại mật khẩu mới',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Mật khẩu không khớp';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Đặt lại mật khẩu',
          onPressed: _isLoading ? null : _resetPassword,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
