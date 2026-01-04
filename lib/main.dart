import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/observers/app_lifecycle_observer.dart';
import 'presentation/view_models/cart_view_model.dart';
import 'presentation/view_models/auth_view_model.dart';
import 'presentation/view_models/wishlist_view_model.dart';
import 'presentation/view_models/order_view_model.dart';
import 'presentation/view_models/search_history_view_model.dart';
import 'presentation/view_models/search_view_model.dart';
import 'presentation/view_models/theme_view_model.dart';
import 'presentation/view_models/notification_view_model.dart';
import 'presentation/view_models/pin_view_model.dart';
import 'presentation/view_models/payment_view_model.dart';
import 'presentation/view_models/admin/admin_dashboard_view_model.dart';
import 'presentation/view_models/admin/admin_product_view_model.dart';
import 'presentation/view_models/admin/admin_order_view_model.dart';
import 'presentation/view_models/admin/admin_user_view_model.dart';
import 'presentation/view_models/admin/admin_coupon_view_model.dart';
import 'presentation/view_models/admin/admin_review_view_model.dart';
import 'presentation/view_models/admin/admin_report_view_model.dart';
import 'presentation/view_models/admin/admin_cart_view_model.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // GlobalKey để có thể navigate từ bất kỳ đâu
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppLifecycleObserver _lifecycleObserver;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AppLifecycleObserver(
      onResumedFromBackground: _onResumedFromBackground,
      backgroundThreshold: const Duration(seconds: 30),
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    // Initialize deep link handling
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle link when app is in foreground
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Handle link that opened the app
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');

    // Handle MoMo payment callback
    if (uri.scheme == 'veritashop' && uri.host == 'momo-return') {
      final context = MyApp.navigatorKey.currentContext;
      if (context != null) {
        final paymentVM = Provider.of<PaymentViewModel>(context, listen: false);
        paymentVM.handleMomoCallback(uri);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  void _onResumedFromBackground() {
    // Sử dụng navigatorKey để access context
    final context = MyApp.navigatorKey.currentContext;
    if (context == null) return;

    final pinVM = Provider.of<PinViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    // Chỉ lock nếu user đã đăng nhập và có PIN enabled
    if (authVM.isAuthenticated && pinVM.isPinEnabled && pinVM.isPinVerified) {
      pinVM.lockApp();

      // Navigate to PIN lock screen
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.pinLock,
        (route) => false,
      );
    }
  }

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
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => PinViewModel()),
        ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        // Admin Providers
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AdminProductViewModel()),
        ChangeNotifierProvider(create: (_) => AdminOrderViewModel()),
        ChangeNotifierProvider(create: (_) => AdminUserViewModel()),
        ChangeNotifierProvider(create: (_) => AdminCouponViewModel()),
        ChangeNotifierProvider(create: (_) => AdminReviewViewModel()),
        ChangeNotifierProvider(create: (_) => AdminReportViewModel()),
        ChangeNotifierProvider(create: (_) => AdminCartViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, child) {
          SystemChrome.setSystemUIOverlayStyle(
            themeVM.isDarkMode
                ? AppTheme.systemOverlayStyleDark
                : AppTheme.systemOverlayStyleLight,
          );

          return MaterialApp(
            navigatorKey: MyApp.navigatorKey,
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
