import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/notification_view_model.dart';
import 'product_list_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

//==============================================================================
// MÀN HÌNH CHÍNH VỚI BOTTOM NAVIGATION BAR
//==============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final colors = AppColors.of(context);

    // Tiêu đề dựa trên tab đang chọn
    String title;
    switch (_selectedIndex) {
      case 0:
        title = 'VeritaShop';
        break;
      case 1:
        title = 'Giỏ hàng';
        break;
      case 2:
        title = 'Thông báo';
        break;
      case 3:
        title = 'Hồ sơ';
        break;
      case 4:
        title = 'Cài đặt';
        break;
      default:
        title = 'VeritaShop';
    }

    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ProductListScreen(embedded: true);
      case 1:
        return const CartScreen(embedded: true);
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ProfileScreen(embedded: true);
      case 4:
        return const SettingsScreen();
      default:
        return const ProductListScreen(embedded: true);
    }
  }

  Widget _buildBottomNavigationBar() {
    final colors = AppColors.of(context);
    return Consumer2<CartViewModel, NotificationViewModel>(
      builder: (context, cartVM, notifVM, _) {
        return BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartVM.itemCount > 0,
                label: Text(
                  cartVM.itemCount > 99 ? '99+' : '${cartVM.itemCount}',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: cartVM.itemCount > 0,
                label: Text(
                  cartVM.itemCount > 99 ? '99+' : '${cartVM.itemCount}',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Giỏ hàng',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: notifVM.unreadCount > 0,
                label: Text(
                  notifVM.unreadCount > 99 ? '99+' : '${notifVM.unreadCount}',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.notifications_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: notifVM.unreadCount > 0,
                label: Text(
                  notifVM.unreadCount > 99 ? '99+' : '${notifVM.unreadCount}',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.notifications),
              ),
              label: 'Thông báo',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Cài đặt',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: colors.card,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kAccentColor,
          unselectedItemColor: colors.secondaryText,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
        );
      },
    );
  }
}
