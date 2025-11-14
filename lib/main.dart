import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar style cho phù hợp với dark mode
    SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlayStyle);

    return MaterialApp(
      title: 'VeritaShop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Màn hình khởi đầu là LoginScreen
      home: AppRoutes.initialRoute,
      // Định nghĩa các named routes
      routes: AppRoutes.routes,
    );
  }
}
