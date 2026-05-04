import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../view_models/auth_view_model.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'admin/admin_shell.dart';

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

    final authViewModel = context.read<AuthViewModel>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await authViewModel.login(email, password);

    if (!mounted) return;

    if (success) {
      final user = authViewModel.currentUser;
      final isAdmin = user?.role == 'admin';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thành công! Xin chào ${user?.name ?? email}'),
          backgroundColor: kGreenColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Điều hướng dựa trên role
      if (isAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminShell(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Đăng nhập thất bại'),
          backgroundColor: kRedColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
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
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kAccentColor.withValues(alpha: 0.2),
            colors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.shopping_bag, size: 56, color: kAccentColor),
          const SizedBox(height: 12),
          Text(
            'Chào mừng đến VeritaShop',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'AI-Powered Shopping Platform',
            style: TextStyle(
              fontSize: 14,
              color: colors.secondaryText,
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
    final colors = AppColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
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
              style: TextStyle(
                fontSize: 11,
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFormCard() {
    final colors = AppColors.of(context);
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
            onPressed: context.watch<AuthViewModel>().isLoading ? null : _handleLogin,
            isLoading: context.watch<AuthViewModel>().isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    final colors = AppColors.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(child: Divider(color: colors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'HOẶC',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.secondaryText.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Expanded(child: Divider(color: colors.border)),
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
                  foregroundColor: colors.primaryText,
                  side: BorderSide(color: colors.border),
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
                  foregroundColor: colors.primaryText,
                  side: BorderSide(color: colors.border),
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
    final colors = AppColors.of(context);
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
          Icon(Icons.person_add, color: colors.secondaryText, size: 18),
          const SizedBox(width: 8),
          Text(
            'Chưa có tài khoản?',
            style: TextStyle(color: colors.secondaryText),
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
