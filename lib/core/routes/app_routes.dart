import 'package:flutter/material.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/product_list_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/cart_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/checkout_screen.dart';
import '../../presentation/screens/order_history_screen.dart';
import '../../presentation/screens/wishlist_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/address_list_screen.dart';
import '../../presentation/screens/admin/admin_login_screen.dart';
import '../../presentation/screens/admin/admin_shell.dart';
import '../../presentation/screens/pin_lock_screen.dart';
import '../../presentation/screens/pin_setup_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String products = '/products';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String wishlist = '/wishlist';
  static const String addresses = '/addresses';
  static const String adminLogin = '/admin-login';
  static const String admin = '/admin';
  static const String pinLock = '/pin-lock';
  static const String pinSetup = '/pin-setup';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      products: (context) => const ProductListScreen(),
      home: (context) => const HomeScreen(),
      cart: (context) => const CartScreen(),
      profile: (context) => const ProfileScreen(),
      checkout: (context) => const CheckoutScreen(),
      orders: (context) => const OrderHistoryScreen(),
      wishlist: (context) => const WishlistScreen(),
      addresses: (context) => const AddressListScreen(),
      adminLogin: (context) => const AdminLoginScreen(),
      admin: (context) => const AdminShell(),
      pinLock: (context) => const PinLockScreen(),
      pinSetup: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map<String, dynamic>) {
          return PinSetupScreen(
            isRequired: args['isRequired'] ?? false,
            isChangingPin: args['isChangingPin'] ?? false,
          );
        }
        return const PinSetupScreen();
      },
    };
  }

  static Widget get initialRoute => const SplashScreen();
}