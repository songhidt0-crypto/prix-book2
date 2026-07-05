import 'package:intl/intl.dart';

/// Date formatting utilities for the app
class DateFormatter {
  static final _dateFormat = DateFormat('dd/MM/yyyy', 'ar');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'ar');
  static final _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Format date to Arabic locale DD/MM/YYYY
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format date+time
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Format as ISO 8601 for DB storage
  static String toIso(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Parse ISO 8601 from DB
  static DateTime fromIso(String iso) {
    return DateTime.parse(iso);
  }

  /// Human-readable "freshness" label for price age
  static String priceAgeLabel(DateTime recordedAt) {
    final now = DateTime.now();
    final diff = now.difference(recordedAt);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسابيع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} أشهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنوات';
  }

  /// Price age in days
  static int priceAgeDays(DateTime recordedAt) {
    return DateTime.now().difference(recordedAt).inDays;
  }

  /// Format duration for session summary
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 1) return 'أقل من دقيقة';
    if (minutes == 1) return 'دقيقة واحدة';
    if (minutes < 60) return '$minutes دقيقة';
    final hours = duration.inHours;
    final mins = minutes % 60;
    if (mins == 0) return '$hours ساعة';
    return '$hours ساعة و$mins دقيقة';
  }
}
