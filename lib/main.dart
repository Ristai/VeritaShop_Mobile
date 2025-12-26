import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'presentation/view_models/cart_view_model.dart';
import 'presentation/view_models/auth_view_model.dart';
import 'presentation/view_models/wishlist_view_model.dart';
import 'presentation/view_models/order_view_model.dart';
import 'presentation/view_models/search_history_view_model.dart';
import 'presentation/view_models/theme_view_model.dart';
import 'presentation/view_models/admin/admin_dashboard_view_model.dart';
import 'presentation/view_models/admin/admin_product_view_model.dart';
import 'presentation/view_models/admin/admin_order_view_model.dart';
import 'presentation/view_models/admin/admin_user_view_model.dart';
import 'presentation/view_models/admin/admin_coupon_view_model.dart';
import 'presentation/view_models/admin/admin_review_view_model.dart';
import 'presentation/view_models/admin/admin_report_view_model.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => SearchHistoryViewModel()),
        // Admin Providers
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AdminProductViewModel()),
        ChangeNotifierProvider(create: (_) => AdminOrderViewModel()),
        ChangeNotifierProvider(create: (_) => AdminUserViewModel()),
        ChangeNotifierProvider(create: (_) => AdminCouponViewModel()),
        ChangeNotifierProvider(create: (_) => AdminReviewViewModel()),
        ChangeNotifierProvider(create: (_) => AdminReportViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, child) {
          SystemChrome.setSystemUIOverlayStyle(
            themeVM.isDarkMode 
                ? AppTheme.systemOverlayStyleDark 
                : AppTheme.systemOverlayStyleLight,
          );
          
          return MaterialApp(
            title: 'VeritaShop',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVM.themeMode,
            home: const SplashScreen(),
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
