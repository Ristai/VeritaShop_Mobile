import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../view_models/auth_view_model.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_users_screen.dart';
import 'admin_coupons_screen.dart';
import 'admin_reviews_screen.dart';
import 'admin_reports_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;
  bool _isExpanded = true;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: 'Sản phẩm'),
    _NavItem(icon: Icons.shopping_bag_outlined, selectedIcon: Icons.shopping_bag, label: 'Đơn hàng'),
    _NavItem(icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Khách hàng'),
    _NavItem(icon: Icons.discount_outlined, selectedIcon: Icons.discount, label: 'Mã giảm giá'),
    _NavItem(icon: Icons.rate_review_outlined, selectedIcon: Icons.rate_review, label: 'Đánh giá'),
    _NavItem(icon: Icons.analytics_outlined, selectedIcon: Icons.analytics, label: 'Báo cáo'),
  ];

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminProductsScreen(),
    const AdminOrdersScreen(),
    const AdminUsersScreen(),
    const AdminCouponsScreen(),
    const AdminReviewsScreen(),
    const AdminReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isWide = MediaQuery.of(context).size.width >= 1200;
    final isMedium = MediaQuery.of(context).size.width >= 768;

    if (!isMedium) {
      return _buildMobileLayout(colors);
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isExpanded ? 260 : 80,
            child: _buildSidebar(colors, isWide),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(colors),
                Expanded(
                  child: Container(
                    color: colors.background,
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kAccentColor, kPurpleColor],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Admin Panel',
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: colors.primaryText),
            onPressed: () {},
          ),
          _buildUserMenu(colors),
        ],
      ),
      drawer: Drawer(
        backgroundColor: colors.card,
        child: _buildDrawerContent(colors),
      ),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildDrawerContent(AppColors colors) {
    final authVm = context.watch<AuthViewModel>();
    
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kAccentColor.withValues(alpha: 0.2),
                  kPurpleColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: kAccentColor,
                  child: Text(
                    authVm.currentUser?.name.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authVm.currentUser?.name ?? 'Admin',
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Quản trị viên',
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? kAccentColor : colors.secondaryText,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? kAccentColor : colors.primaryText,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: kAccentColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: kRedColor),
            title: const Text('Đăng xuất', style: TextStyle(color: kRedColor)),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebar(AppColors colors, bool isWide) {
    final authVm = context.watch<AuthViewModel>();
    
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          right: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kAccentColor, kPurpleColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VeritaShop',
                          style: TextStyle(
                            color: colors.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Toggle Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: _isExpanded ? MainAxisAlignment.end : MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                      color: colors.secondaryText,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: _isExpanded ? 16 : 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? kAccentColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: kAccentColor.withValues(alpha: 0.3))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? kAccentColor : colors.secondaryText,
                              size: 22,
                            ),
                            if (_isExpanded) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected ? kAccentColor : colors.primaryText,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (index == 2) // Orders - show badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kRedColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Mới',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // User Section - Wrap với SafeArea để tránh overflow
          SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: kAccentColor,
                    child: Text(
                      authVm.currentUser?.name.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            authVm.currentUser?.name ?? 'Admin',
                            style: TextStyle(
                              color: colors.primaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Quản trị viên',
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout, size: 18),
                        color: kRedColor,
                        padding: EdgeInsets.zero,
                        tooltip: 'Đăng xuất',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(AppColors colors) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Page Title
          Text(
            _navItems[_selectedIndex].label,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Search
          Container(
            width: 300,
            height: 42,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                hintStyle: TextStyle(color: colors.secondaryText, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: colors.secondaryText, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Notifications
          _buildIconButton(colors, Icons.notifications_outlined, badge: 3),
          const SizedBox(width: 8),
          // Settings
          _buildIconButton(colors, Icons.settings_outlined),
          const SizedBox(width: 16),
          // User Menu
          _buildUserMenu(colors),
        ],
      ),
    );
  }

  Widget _buildIconButton(AppColors colors, IconData icon, {int? badge}) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(icon, color: colors.primaryText, size: 20),
          ),
        ),
        if (badge != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: kRedColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserMenu(AppColors colors) {
    final authVm = context.watch<AuthViewModel>();
    
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: kAccentColor,
              child: Text(
                authVm.currentUser?.name.substring(0, 1).toUpperCase() ?? 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, color: colors.secondaryText, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kAccentColor,
              child: Text(
                authVm.currentUser?.name.substring(0, 1).toUpperCase() ?? 'A',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(authVm.currentUser?.name ?? 'Admin'),
            subtitle: Text(authVm.currentUser?.email ?? ''),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: colors.secondaryText),
              const SizedBox(width: 12),
              const Text('Hồ sơ'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, color: colors.secondaryText),
              const SizedBox(width: 12),
              const Text('Cài đặt'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: const Row(
            children: [
              Icon(Icons.logout, color: kRedColor),
              SizedBox(width: 12),
              Text('Đăng xuất', style: TextStyle(color: kRedColor)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          _handleLogout(context);
        }
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: kRedColor),
            SizedBox(width: 12),
            Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kRedColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    
    if (confirm == true && context.mounted) {
      await context.read<AuthViewModel>().logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
