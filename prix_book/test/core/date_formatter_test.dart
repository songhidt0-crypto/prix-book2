import 'package:flutter_test/flutter_test.dart';
import 'package:prix_book/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formatDate formats as DD/MM/YYYY', () {
      final date = DateTime(2024, 6, 5);
      final result = DateFormatter.formatDate(date);
      expect(result, contains('05'));
      expect(result, contains('06'));
      expect(result, contains('2024'));
    });

    test('toIso and fromIso are inverses', () {
      final original = DateTime(2024, 3, 14, 12, 30, 0);
      final iso = DateFormatter.toIso(original);
      final parsed = DateFormatter.fromIso(iso);
      expect(parsed.year, original.year);
      expect(parsed.month, original.month);
      expect(parsed.day, original.day);
    });

    test('priceAgeDays returns 0 for now', () {
      final days = DateFormatter.priceAgeDays(DateTime.now());
      expect(days, 0);
    });

    test('priceAgeDays returns correct days', () {
      final past = DateTime.now().subtract(const Duration(days: 10));
      expect(DateFormatter.priceAgeDays(past), 10);
    });

    test('priceAgeLabel returns "اليوم" for today', () {
      expect(DateFormatter.priceAgeLabel(DateTime.now()), 'اليوم');
    });

    test('priceAgeLabel returns "أمس" for yesterday', () {
      final yesterday =
          DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.priceAgeLabel(yesterday), 'أمس');
    });

    test('formatDuration returns correct label', () {
      expect(DateFormatter.formatDuration(const Duration(minutes: 0)),
          'أقل من دقيقة');
      expect(DateFormatter.formatDuration(const Duration(minutes: 1)),
          'دقيقة واحدة');
      expect(DateFormatter.formatDuration(const Duration(minutes: 30)),
          '30 دقيقة');
      expect(DateFormatter.formatDuration(const Duration(hours: 1)),
          '1 ساعة');
      expect(
          DateFormatter.formatDuration(const Duration(hours: 1, minutes: 30)),
          '1 ساعة و30 دقيقة');
    });
  });
}
