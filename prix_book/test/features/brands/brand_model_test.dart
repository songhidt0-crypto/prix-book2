import 'package:flutter_test/flutter_test.dart';
import 'package:prix_book/features/brands/data/brand_model.dart';

void main() {
  final now = DateTime(2024, 6, 15, 10, 0, 0);

  group('BrandModel', () {
    test('fromMap deserializes correctly', () {
      final map = {
        'id': 1,
        'name': 'BIC',
        'notes': 'فرنسية',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final brand = BrandModel.fromMap(map);
      expect(brand.id, 1);
      expect(brand.name, 'BIC');
      expect(brand.notes, 'فرنسية');
    });

    test('toMap serializes correctly', () {
      final brand = BrandModel(
        id: 2,
        name: 'Maped',
        notes: null,
        createdAt: now,
        updatedAt: now,
      );
      final map = brand.toMap();
      expect(map['id'], 2);
      expect(map['name'], 'Maped');
      expect(map['notes'], isNull);
      expect(map['created_at'], now.toIso8601String());
    });

    test('toMap excludes id when null (for INSERT)', () {
      final brand = BrandModel(
        name: 'Pilot',
        notes: null,
        createdAt: now,
        updatedAt: now,
      );
      final map = brand.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('roundtrip fromMap->toMap preserves data', () {
      final original = {
        'id': 5,
        'name': 'Staedtler',
        'notes': 'ألمانية',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final model = BrandModel.fromMap(original);
      final serialized = model.toMap();
      expect(serialized['name'], original['name']);
      expect(serialized['notes'], original['notes']);
    });
  });
}
