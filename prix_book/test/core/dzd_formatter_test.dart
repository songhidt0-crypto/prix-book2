import 'package:flutter_test/flutter_test.dart';
import 'package:prix_book/core/utils/dzd_formatter.dart';

void main() {
  group('DZDFormatter', () {
    test('formats small price correctly', () {
      expect(DZDFormatter.format(250), '250 دج');
    });

    test('formats thousands with space separator', () {
      expect(DZDFormatter.format(1250), '1 250 دج');
      expect(DZDFormatter.format(10000), '10 000 دج');
      expect(DZDFormatter.format(1000000), '1 000 000 دج');
    });

    test('formatNumber returns number only without DZD', () {
      expect(DZDFormatter.formatNumber(1500), '1 500');
      expect(DZDFormatter.formatNumber(99), '99');
    });

    test('formatUnitPrice formats correctly', () {
      final result = DZDFormatter.formatUnitPrice(25, 'قطعة');
      expect(result, contains('25'));
      expect(result, contains('دج'));
      expect(result, contains('قطعة'));
    });

    test('truncates decimal portion', () {
      expect(DZDFormatter.format(1250.99), '1 250 دج');
    });
  });
}
