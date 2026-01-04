import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiService.instance.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công'),
            backgroundColor: kGreenColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Đổi mật khẩu thất bại';
        if (e.toString().contains('incorrect') || e.toString().contains('wrong')) {
          errorMessage = 'Mật khẩu hiện tại không đúng';
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'Lỗi kết nối mạng';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: kRedColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: const Text('Đổi mật khẩu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cập nhật mật khẩu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập mật khẩu hiện tại và mật khẩu mới để cập nhật',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.secondaryText,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Mật khẩu hiện tại',
                hint: 'Nhập mật khẩu hiện tại',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _newPasswordController,
                label: 'Mật khẩu mới',
                hint: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                prefixIcon: Icons.lock,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  if (value == _currentPasswordController.text) {
                    return 'Mật khẩu mới phải khác mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu mới',
                hint: 'Nhập lại mật khẩu mới',
                prefixIcon: Icons.lock,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu mới';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _isLoading ? 'Đang xử lý...' : 'Đổi mật khẩu',
                onPressed: _isLoading ? null : _changePassword,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: kAccentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
