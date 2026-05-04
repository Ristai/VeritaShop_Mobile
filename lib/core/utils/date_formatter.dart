import 'package:intl/intl.dart';

/// Helper class để format datetime theo timezone Việt Nam (UTC+7)
class DateFormatter {
  /// Vietnam timezone offset: UTC+7
  static const int _vietnamOffsetHours = 7;

  /// Convert DateTime (UTC) sang Vietnam timezone (UTC+7)
  /// Nếu input đã là local time, sẽ convert từ UTC rồi mới add offset
  static DateTime toVietnamTime(DateTime dateTime) {
    // Đảm bảo datetime là UTC trước khi convert
    final utc = dateTime.isUtc ? dateTime : dateTime.toUtc();
    // Add 7 hours for Vietnam timezone
    return utc.add(const Duration(hours: _vietnamOffsetHours));
  }

  /// Format datetime theo format Việt Nam: dd/MM/yyyy HH:mm
  /// Tự động convert sang UTC+7
  static String formatVietnamDateTime(DateTime dateTime) {
    final vnTime = toVietnamTime(dateTime);
    return DateFormat('dd/MM/yyyy HH:mm').format(vnTime);
  }

  /// Format date only theo format Việt Nam: dd/MM/yyyy
  /// Tự động convert sang UTC+7
  static String formatVietnamDate(DateTime dateTime) {
    final vnTime = toVietnamTime(dateTime);
    return DateFormat('dd/MM/yyyy').format(vnTime);
  }

  /// Format time only: HH:mm
  /// Tự động convert sang UTC+7
  static String formatVietnamTime(DateTime dateTime) {
    final vnTime = toVietnamTime(dateTime);
    return DateFormat('HH:mm').format(vnTime);
  }

  /// Format datetime relative (hôm nay, hôm qua, etc.)
  /// Tự động convert sang UTC+7
  static String formatRelativeDate(DateTime dateTime) {
    final vnTime = toVietnamTime(dateTime);
    final now = toVietnamTime(DateTime.now().toUtc());
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(vnTime.year, vnTime.month, vnTime.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) {
      return 'Hôm nay ${DateFormat('HH:mm').format(vnTime)}';
    } else if (diff == 1) {
      return 'Hôm qua ${DateFormat('HH:mm').format(vnTime)}';
    } else if (diff < 7) {
      return '$diff ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(vnTime);
    }
  }

  /// Parse datetime string từ API và convert sang Vietnam time
  static DateTime? parseAndConvert(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return null;
    return toVietnamTime(parsed);
  }
}

/// Shortcut functions để sử dụng nhanh
DateTime toVietnamTime(DateTime dateTime) => DateFormatter.toVietnamTime(dateTime);
String formatVietnamDateTime(DateTime dateTime) => DateFormatter.formatVietnamDateTime(dateTime);
String formatVietnamDate(DateTime dateTime) => DateFormatter.formatVietnamDate(dateTime);
