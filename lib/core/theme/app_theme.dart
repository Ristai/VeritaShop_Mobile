import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Cấu hình theme cho ứng dụng VeritaShop
class AppTheme {
  /// Theme tối của ứng dụng (Dark mode)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBackgroundColorDark,
      primaryColor: kAccentColor,
      colorScheme: const ColorScheme.dark(
        primary: kAccentColor,
        secondary: kPurpleColor,
        surface: kCardColorDark,
        error: kRedColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: kPrimaryTextColorDark,
        displayColor: kPrimaryTextColorDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackgroundColorDark,
        foregroundColor: kPrimaryTextColorDark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: kCardColorDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorderColorDark),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kCardColorDark,
        selectedItemColor: kAccentColor,
        unselectedItemColor: kSecondaryTextColorDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: kCardColorDark,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentColor),
        ),
        hintStyle: const TextStyle(color: kSecondaryTextColorDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kAccentColor,
          side: const BorderSide(color: kAccentColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kAccentColor,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: kBorderColorDark,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kCardColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: kCardColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kCardColorDark,
        contentTextStyle: const TextStyle(color: kPrimaryTextColorDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kAccentColor;
          }
          return kSecondaryTextColorDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kAccentColor.withValues(alpha: 0.5);
          }
          return kBorderColorDark;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kAccentColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: kCardColorDark,
        selectedColor: kAccentColor.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: kPrimaryTextColorDark),
        side: const BorderSide(color: kBorderColorDark),
      ),
    );
  }

  /// Theme sáng của ứng dụng (Light mode)
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: kBackgroundColorLight,
      primaryColor: kAccentColor,
      colorScheme: const ColorScheme.light(
        primary: kAccentColor,
        secondary: kPurpleColor,
        surface: kCardColorLight,
        error: kRedColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: kPrimaryTextColorLight,
        displayColor: kPrimaryTextColorLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackgroundColorLight,
        foregroundColor: kPrimaryTextColorLight,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: kPrimaryTextColorLight),
      ),
      cardTheme: CardThemeData(
        color: kCardColorLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorderColorLight),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kCardColorLight,
        selectedItemColor: kAccentColor,
        unselectedItemColor: kSecondaryTextColorLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: kCardColorLight,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColorLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColorLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentColor),
        ),
        hintStyle: const TextStyle(color: kSecondaryTextColorLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kAccentColor,
          side: const BorderSide(color: kAccentColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kAccentColor,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: kBorderColorLight,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kCardColorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: kCardColorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kPrimaryTextColorLight,
        contentTextStyle: const TextStyle(color: kCardColorLight),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kAccentColor;
          }
          return kSecondaryTextColorLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kAccentColor.withValues(alpha: 0.5);
          }
          return kBorderColorLight;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kAccentColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: kBorderColorLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: kCardColorLight,
        selectedColor: kAccentColor.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: kPrimaryTextColorLight),
        side: const BorderSide(color: kBorderColorLight),
      ),
    );
  }

  /// Cấu hình system UI overlay style cho Dark mode
  static SystemUiOverlayStyle get systemOverlayStyleDark {
    return SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: kCardColorDark,
    );
  }

  /// Cấu hình system UI overlay style cho Light mode
  static SystemUiOverlayStyle get systemOverlayStyleLight {
    return SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: kCardColorLight,
    );
  }

  /// Legacy - kept for backward compatibility
  static SystemUiOverlayStyle get systemOverlayStyle => systemOverlayStyleDark;
}

