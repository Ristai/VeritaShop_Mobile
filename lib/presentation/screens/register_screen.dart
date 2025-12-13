import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'product_list_screen.dart';

/// Màn hình đăng ký - Onboarding Journey
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên';
    }
    if (value.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    if (RegExp(r'\d').hasMatch(value)) {
      return 'Tên không được chứa số';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value)) {
      return 'Mật khẩu phải có cả chữ và số';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng'),
          backgroundColor: kRedColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    final name = _nameController.text.trim();
    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đăng ký thành công! Chào mừng $name'),
        backgroundColor: kGreenColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const ProductListScreen(),
      ),
      (route) => false,
    );
  }

  void _showTermsDialog() {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Điều khoản sử dụng', style: TextStyle(color: colors.primaryText)),
        content: SingleChildScrollView(
          child: Text(
            'Đây là điều khoản sử dụng mẫu cho VeritaShop.\n\n'
            '1. Bạn phải từ 18 tuổi trở lên để sử dụng dịch vụ.\n'
            '2. Thông tin cá nhân của bạn sẽ được bảo mật.\n'
            '3. Bạn chịu trách nhiệm về tài khoản của mình.\n'
            '4. Chúng tôi có quyền từ chối dịch vụ với bất kỳ ai.\n'
            '5. Các điều khoản có thể thay đổi mà không cần báo trước.\n\n'
            'Bằng việc đăng ký, bạn đồng ý với các điều khoản trên.',
            style: TextStyle(color: colors.secondaryText),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tạo tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.primaryText),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcomeBanner(colors),
                  const SizedBox(height: 24),
                  _buildBenefitsRow(colors),
                  const SizedBox(height: 24),
                  _buildRegistrationFormCard(colors),
                  const SizedBox(height: 24),
                  _buildTermsCard(colors),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Tạo tài khoản',
                    icon: Icons.check_circle,
                    onPressed: _isLoading ? null : _handleRegister,
                    isLoading: _isLoading,
                    width: double.infinity,
                    height: 56,
                  ),
                  const SizedBox(height: 16),
                  _buildBackToLoginCard(colors),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kGreenColor.withValues(alpha: 0.15),
            colors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kGreenColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.celebration,
              color: kGreenColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bắt đầu hành trình!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tạo tài khoản để trải nghiệm mua sắm tốt nhất',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsRow(AppColors colors) {
    return Row(
      children: [
        _buildBenefitCard(
          icon: Icons.local_shipping,
          title: 'Miễn phí\nvận chuyển',
          color: kGreenColor,
          colors: colors,
        ),
        const SizedBox(width: 12),
        _buildBenefitCard(
          icon: Icons.loyalty,
          title: 'Tích điểm\nthưởng',
          color: kYellowColor,
          colors: colors,
        ),
        const SizedBox(width: 12),
        _buildBenefitCard(
          icon: Icons.notifications_active,
          title: 'Ưu đãi\nđặc biệt',
          color: kAccentColor,
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required Color color,
    required AppColors colors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationFormCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_outlined, color: kAccentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Thông tin tài khoản',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.primaryText),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _nameController,
            label: 'Họ và tên',
            hint: 'Nguyễn Văn A',
            prefixIcon: Icons.person_outline,
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'your@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Mật khẩu',
            hint: 'Tối thiểu 6 ký tự, có chữ và số',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            hint: 'Nhập lại mật khẩu',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: _validateConfirmPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() => _acceptTerms = value ?? false);
              },
              activeColor: kAccentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _showTermsDialog,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: colors.secondaryText),
                  children: const [
                    TextSpan(text: 'Tôi đồng ý với '),
                    TextSpan(
                      text: 'Điều khoản sử dụng',
                      style: TextStyle(
                        color: kAccentColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' của VeritaShop'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLoginCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back, color: colors.secondaryText, size: 16),
          const SizedBox(width: 8),
          Text(
            'Đã có tài khoản?',
            style: TextStyle(color: colors.secondaryText),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Text(
              'Đăng nhập ngay',
              style: TextStyle(
                color: kAccentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
