import 'package:flutter_test/flutter_test.dart';
import 'package:prix_book/core/utils/validators.dart';

void main() {
  group('Validators.productName', () {
    test('returns error for empty string', () {
      expect(Validators.productName(''), isNotNull);
      expect(Validators.productName(null), isNotNull);
      expect(Validators.productName('   '), isNotNull);
    });

    test('returns null for valid name', () {
      expect(Validators.productName('قلم بيك'), isNull);
      expect(Validators.productName('A'), isNull);
    });

    test('returns error for name exceeding 100 chars', () {
      final long = 'أ' * 101;
      expect(Validators.productName(long), isNotNull);
    });

    test('accepts exactly 100 chars', () {
      final exactly100 = 'أ' * 100;
      expect(Validators.productName(exactly100), isNull);
    });
  });

  group('Validators.price', () {
    test('returns error for empty', () {
      expect(Validators.price(''), isNotNull);
      expect(Validators.price(null), isNotNull);
    });

    test('returns error for zero or negative', () {
      expect(Validators.price('0'), isNotNull);
      expect(Validators.price('-5'), isNotNull);
    });

    test('returns null for positive price', () {
      expect(Validators.price('250'), isNull);
      expect(Validators.price('1500.5'), isNull);
    });

    test('returns error for price > 9999999', () {
      expect(Validators.price('10000000'), isNotNull);
    });

    test('accepts max boundary 9999999', () {
      expect(Validators.price('9999999'), isNull);
    });
  });

  group('Validators.packSize', () {
    test('returns null for empty (optional)', () {
      expect(Validators.packSize(''), isNull);
      expect(Validators.packSize(null), isNull);
    });

    test('returns error for zero or negative', () {
      expect(Validators.packSize('0'), isNotNull);
      expect(Validators.packSize('-1'), isNotNull);
    });

    test('returns null for positive value', () {
      expect(Validators.packSize('12'), isNull);
    });
  });

  group('Validators.phone', () {
    test('returns null for empty (optional)', () {
      expect(Validators.phone(''), isNull);
      expect(Validators.phone(null), isNull);
    });

    test('returns null for valid Algerian phone', () {
      expect(Validators.phone('0555123456'), isNull);
      expect(Validators.phone('+213555123456'), isNull);
    });

    test('returns error for too short', () {
      expect(Validators.phone('123'), isNotNull);
    });
  });

  group('Validators.lastVisitDate', () {
    test('returns null for null date', () {
      expect(Validators.lastVisitDate(null), isNull);
    });

    test('returns null for past date', () {
      expect(
        Validators.lastVisitDate(DateTime.now().subtract(const Duration(days: 1))),
        isNull,
      );
    });

    test('returns error for future date', () {
      expect(
        Validators.lastVisitDate(DateTime.now().add(const Duration(days: 1))),
        isNotNull,
      );
    });
  });
}
