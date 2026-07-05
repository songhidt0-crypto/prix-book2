import '../constants/app_strings.dart';

/// Algerian Dinar formatter
/// DZD prices are whole numbers with space as thousands separator
/// per French convention as specified in v1.1 Section 8.1
class DZDFormatter {
  /// Format a price as "1 250 دج"
  static String format(double price) {
    final intPrice = price.toInt();
    final formatted = _formatWithSpaces(intPrice);
    return '$formatted ${AppStrings.dzd}';
  }

  /// Format just the number with space thousands separator
  static String formatNumber(double price) {
    return _formatWithSpaces(price.toInt());
  }

  /// Format unit price as "= N دج / قطعة"
  static String formatUnitPrice(double price, String unitLabel) {
    final formatted = formatNumber(price);
    return '= $formatted ${AppStrings.dzd} / $unitLabel';
  }

  static String _formatWithSpaces(int number) {
    final s = number.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        result.write(' ');
      }
      result.write(s[i]);
    }
    return result.toString();
  }
}
