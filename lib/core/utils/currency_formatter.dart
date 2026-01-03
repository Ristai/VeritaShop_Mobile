import 'package:intl/intl.dart';

/// Helper class để format giá tiền theo chuẩn Việt Nam
class CurrencyFormatter {
  static final NumberFormat _vnFormat = NumberFormat('#,###', 'vi_VN');

  /// Format giá tiền theo chuẩn VN: 200.000 VND
  /// [price] - giá tiền dạng số (ví dụ: 200000)
  /// Returns: String đã format (ví dụ: "200.000 VND")
  static String formatVND(double price) {
    final formatted = _vnFormat.format(price.round());
    // NumberFormat với vi_VN sử dụng dấu chấm làm separator
    return '$formatted VND';
  }

  /// Format giá tiền với dấu âm cho discount: -200.000 VND
  static String formatVNDDiscount(double price) {
    final formatted = _vnFormat.format(price.round());
    return '-$formatted VND';
  }
}

/// Shortcut function để format VND
String formatVND(double price) => CurrencyFormatter.formatVND(price);

/// Shortcut function để format VND discount
String formatVNDDiscount(double price) => CurrencyFormatter.formatVNDDiscount(price);
