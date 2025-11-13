import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Import các screens
import 'package:veritashop/screens/login_screen.dart';
import 'package:veritashop/screens/register_screen.dart';
import 'package:veritashop/screens/product_list_screen.dart';
import 'package:veritashop/screens/home_screen.dart';
import 'package:veritashop/view_models/color_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar style cho phù hợp với dark mode
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return MaterialApp(
      title: 'VeritaShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackgroundColor,
        // Sử dụng Google Fonts để giao diện đẹp hơn
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackgroundColor,
          elevation: 0,
        ),
      ),
      // Màn hình khởi đầu là LoginScreen
      home: const LoginScreen(),
      // Định nghĩa các named routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/products': (context) => const ProductListScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
