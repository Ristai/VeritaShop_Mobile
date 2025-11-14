import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';
import 'product_list_screen.dart';

/// Màn hình đăng nhập - Welcome Portal
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    final email = _emailController.text.trim();
    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đăng nhập thành công! Xin chào $email'),
        backgroundColor: kGreenColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ProductListScreen(),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text('Quên mật khẩu'),
        content: const Text(
          'Tính năng đặt lại mật khẩu sẽ được cập nhật sớm. Vui lòng liên hệ admin để được hỗ trợ.',
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
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Banner
                  _buildHeroBanner(),
                  const SizedBox(height: 32),

                  // Quick Stats Row
                  _buildQuickStatsRow(),
                  const SizedBox(height: 32),

                  // Login Form Card
                  _buildLoginFormCard(),
                  const SizedBox(height: 24),

                  // Social Login Section
                  _buildSocialLoginSection(),
                  const SizedBox(height: 24),

                  // Register CTA
                  _buildRegisterCTA(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kAccentColor.withValues(alpha: 0.2),
            kCardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.shopping_bag, size: 56, color: kAccentColor),
          SizedBox(height: 12),
          Text(
            'Chào mừng đến VeritaShop',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'AI-Powered Shopping Platform',
            style: TextStyle(
              fontSize: 14,
              color: kSecondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        _buildMiniStatCard(
          icon: Icons.inventory_2,
          value: '1,234',
          label: 'Sản phẩm',
        ),
        const SizedBox(width: 12),
        _buildMiniStatCard(
          icon: Icons.people,
          value: '5.6K',
          label: 'Khách hàng',
        ),
        const SizedBox(width: 12),
        _buildMiniStatCard(
          icon: Icons.star,
          value: '4.8',
          label: 'Đánh giá',
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: kAccentColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: kSecondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.login, color: kAccentColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Đăng nhập',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

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
            hint: 'Nhập mật khẩu',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 12),

          // Remember me & Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      activeColor: kAccentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ghi nhớ',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
              TextButton(
                onPressed: _handleForgotPassword,
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(fontSize: 13, color: kAccentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CustomButton(
            text: 'Đăng nhập',
            icon: Icons.arrow_forward,
            onPressed: _isLoading ? null : _handleLogin,
            isLoading: _isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Expanded(child: Divider(color: kBorderColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'HOẶC',
                  style: TextStyle(
                    fontSize: 11,
                    color: kSecondaryTextColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const Expanded(child: Divider(color: kBorderColor)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng sẽ được cập nhật sớm'),
                    ),
                  );
                },
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryTextColor,
                  side: const BorderSide(color: kBorderColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng sẽ được cập nhật sớm'),
                    ),
                  );
                },
                icon: const Icon(Icons.facebook, size: 20),
                label: const Text('Facebook'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryTextColor,
                  side: const BorderSide(color: kBorderColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterCTA() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add, color: kSecondaryTextColor, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Chưa có tài khoản?',
            style: TextStyle(color: kSecondaryTextColor),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _navigateToRegister,
            child: const Text(
              'Đăng ký ngay',
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
