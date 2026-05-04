import 'package:flutter/material.dart';

/// Hằng số màu sắc cho ứng dụng VeritaShop
/// Tất cả các màu được sử dụng trong ứng dụng nên được định nghĩa ở đây

// =============================================================================
// DARK THEME COLORS (Default)
// =============================================================================

// Background colors - Dark
const Color kBackgroundColorDark = Color(0xFF0A0E27);
const Color kCardColorDark = Color(0xFF1A1F3A);
const Color kBorderColorDark = Color(0xFF2A2F4A);

// Text colors - Dark
const Color kPrimaryTextColorDark = Color(0xFFFFFFFF);
const Color kSecondaryTextColorDark = Color(0xFF9CA3AF);

// =============================================================================
// LIGHT THEME COLORS
// =============================================================================

// Background colors - Light
const Color kBackgroundColorLight = Color(0xFFF5F7FA);
const Color kCardColorLight = Color(0xFFFFFFFF);
const Color kBorderColorLight = Color(0xFFE5E7EB);

// Text colors - Light
const Color kPrimaryTextColorLight = Color(0xFF1F2937);
const Color kSecondaryTextColorLight = Color(0xFF6B7280);

// =============================================================================
// ACCENT COLORS (Same for both themes)
// =============================================================================

const Color kAccentColor = Color(0xFF6366F1); // Indigo
const Color kGreenColor = Color(0xFF10B981);
const Color kRedColor = Color(0xFFEF4444);
const Color kYellowColor = Color(0xFFF59E0B);
const Color kPurpleColor = Color(0xFF8B5CF6);

// =============================================================================
// LEGACY CONSTANTS (For backward compatibility - will use dark theme colors)
// These are kept for existing code that uses the old constant names
// =============================================================================

const Color kBackgroundColor = kBackgroundColorDark;
const Color kCardColor = kCardColorDark;
const Color kBorderColor = kBorderColorDark;
const Color kPrimaryTextColor = kPrimaryTextColorDark;
const Color kSecondaryTextColor = kSecondaryTextColorDark;

// =============================================================================
// DYNAMIC COLOR HELPER CLASS
// =============================================================================

class AppColors {
  final bool isDark;

  AppColors({required this.isDark});

  // Background colors
  Color get background => isDark ? kBackgroundColorDark : kBackgroundColorLight;
  Color get card => isDark ? kCardColorDark : kCardColorLight;
  Color get border => isDark ? kBorderColorDark : kBorderColorLight;

  // Text colors
  Color get primaryText => isDark ? kPrimaryTextColorDark : kPrimaryTextColorLight;
  Color get secondaryText => isDark ? kSecondaryTextColorDark : kSecondaryTextColorLight;

  // Accent colors (same for both themes)
  Color get accent => kAccentColor;
  Color get green => kGreenColor;
  Color get red => kRedColor;
  Color get yellow => kYellowColor;
  Color get purple => kPurpleColor;

  // Static helper to get colors from context
  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppColors(isDark: brightness == Brightness.dark);
  }
}

