import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/wishlist_view_model.dart';
import '../view_models/order_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().checkAuthStatus();
    });
  }

  void _logout() async {
    final colors = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất', style: TextStyle(color: kRedColor)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<AuthViewModel>().logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: kRedColor,
          ),
        );
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
        title: const Text('Thông tin cá nhân'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          if (authViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final user = authViewModel.currentUser;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(user),
                _buildStatistics(),
                _buildProfileOptions(),
                _buildLogoutSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    final colors = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: kAccentColor,
            backgroundImage: user?.avatarUrl != null 
                ? NetworkImage(user!.avatarUrl)
                : null,
            child: user?.avatarUrl == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Khách',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'Chưa đăng nhập',
            style: TextStyle(
              fontSize: 16,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng chỉnh sửa thông tin sẽ sớm được cập nhật'),
                  backgroundColor: kYellowColor,
                ),
              );
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Chỉnh sửa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kAccentColor,
              side: const BorderSide(color: kAccentColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final colors = AppColors.of(context);
    return Consumer3<OrderViewModel, CartViewModel, WishlistViewModel>(
      builder: (context, orderVM, cartVM, wishlistVM, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.card,
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Đơn hàng',
                count: orderVM.orders.length,
                onTap: () => Navigator.pushNamed(context, '/orders'),
              ),
              _buildStatItem(
                icon: Icons.favorite_border,
                label: 'Yêu thích',
                count: wishlistVM.itemCount,
                onTap: () => Navigator.pushNamed(context, '/wishlist'),
              ),
              _buildStatItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Giỏ hàng',
                count: cartVM.itemCount,
                onTap: () => Navigator.pushNamed(context, '/cart'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kAccentColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildOptionItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Đơn hàng của tôi',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          Divider(color: colors.border, height: 1),
          _buildOptionItem(
            icon: Icons.favorite_border,
            title: 'Sản phẩm yêu thích',
            onTap: () => Navigator.pushNamed(context, '/wishlist'),
          ),
          Divider(color: colors.border, height: 1),
          _buildOptionItem(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ giao hàng',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng thêm địa chỉ khi thanh toán'),
                  backgroundColor: kYellowColor,
                ),
              );
            },
          ),
          Divider(color: colors.border, height: 1),
          _buildOptionItem(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng cài đặt sẽ sớm được cập nhật'),
                  backgroundColor: kYellowColor,
                ),
              );
            },
          ),
          Divider(color: colors.border, height: 1),
          _buildOptionItem(
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    return ListTile(
      leading: Icon(icon, color: colors.secondaryText),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colors.secondaryText),
      onTap: onTap,
    );
  }

  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomButton(
        text: 'Đăng xuất',
        onPressed: _logout,
        isPrimary: false,
      ),
    );
  }
}
