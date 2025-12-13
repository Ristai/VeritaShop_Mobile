import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.shopping_bag_outlined,
      title: 'Mua sắm dễ dàng',
      description: 'Khám phá hàng ngàn sản phẩm chất lượng với giá tốt nhất tại VeritaShop',
      color: kAccentColor,
    ),
    OnboardingItem(
      icon: Icons.psychology_outlined,
      title: 'AI Phân tích thông minh',
      description: 'Công nghệ AI giúp bạn đọc và hiểu đánh giá sản phẩm một cách nhanh chóng',
      color: kPurpleColor,
    ),
    OnboardingItem(
      icon: Icons.local_shipping_outlined,
      title: 'Giao hàng nhanh chóng',
      description: 'Đơn hàng được giao tận nơi với nhiều phương thức thanh toán linh hoạt',
      color: kGreenColor,
    ),
    OnboardingItem(
      icon: Icons.security_outlined,
      title: 'An toàn & Bảo mật',
      description: 'Thông tin của bạn được bảo vệ với công nghệ mã hóa tiên tiến',
      color: kYellowColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentPage + 1}/${_items.length}',
                    style: const TextStyle(
                      color: kSecondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Bỏ qua',
                      style: TextStyle(color: kAccentColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _buildPage(_items[index]),
              ),
            ),
            _buildDots(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: _currentPage == _items.length - 1 ? 'Bắt đầu' : 'Tiếp tục',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 80,
              color: item.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 16,
              color: kSecondaryTextColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_items.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? kAccentColor : kBorderColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
