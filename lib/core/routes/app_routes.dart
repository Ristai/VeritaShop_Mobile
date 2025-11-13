import 'package:flutter/material.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/product_list_screen.dart';
import '../../presentation/screens/home_screen.dart';

/// Định nghĩa các routes cho ứng dụng
class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String products = '/products';
  static const String home = '/home';

  /// Map các routes với các màn hình tương ứng
  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      products: (context) => const ProductListScreen(),
      home: (context) => const HomeScreen(),
    };
  }

  /// Màn hình khởi đầu của ứng dụng
  static Widget get initialRoute => const LoginScreen();
}

