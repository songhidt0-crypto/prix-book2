import 'package:flutter_test/flutter_test.dart';
import 'package:prix_book/core/constants/unit_types.dart';
import 'package:prix_book/features/prices/domain/entities/price_record.dart';

PriceRecord _makeRecord({
  required double price,
  int? packSize,
}) {
  final now = DateTime.now();
  return PriceRecord(
    productId: 1,
    supplierId: 1,
    price: price,
    unitTypeSnapshot: UnitType.box,
    packSizeSnapshot: packSize,
    recordedAt: now,
    createdAt: now,
  );
}

void main() {
  group('PriceRecord.unitPrice', () {
    test('returns null when pack size is null', () {
      final r = _makeRecord(price: 500);
      expect(r.unitPrice, isNull);
    });

    test('returns price / packSize for box of 12', () {
      final r = _makeRecord(price: 1200, packSize: 12);
      expect(r.unitPrice, closeTo(100, 0.01));
    });

    test('comparisonPrice equals unitPrice when packSize provided', () {
      final r = _makeRecord(price: 600, packSize: 6);
      expect(r.comparisonPrice, closeTo(r.unitPrice!, 0.001));
    });

    test('comparisonPrice equals price when no packSize', () {
      final r = _makeRecord(price: 350);
      expect(r.comparisonPrice, 350);
    });
  });

  group('PriceRecord.isActive session', () {
    test('records with sessionId are tied to session', () {
      final now = DateTime.now();
      final r = PriceRecord(
        productId: 1,
        supplierId: 1,
        sessionId: 42,
        price: 200,
        unitTypeSnapshot: UnitType.piece,
        recordedAt: now,
        createdAt: now,
      );
      expect(r.sessionId, 42);
    });
  });
}
