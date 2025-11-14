import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Cấu hình theme cho ứng dụng VeritaShop
class AppTheme {
  /// Theme chính của ứng dụng (Dark mode)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBackgroundColor,
      // Sử dụng Google Fonts để giao diện đẹp hơn
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      // Có thể thêm các theme configurations khác ở đây
    );
  }

  /// Cấu hình system UI overlay style
  static SystemUiOverlayStyle get systemOverlayStyle {
    return SystemUiOverlayStyle.light;
  }
}

