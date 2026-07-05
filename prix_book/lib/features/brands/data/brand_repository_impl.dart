import 'package:sqflite/sqflite.dart';
import '../../../core/utils/database_helper.dart';
import '../domain/entities/brand.dart';
import '../domain/repositories/i_brand_repository.dart';
import 'brand_model.dart';

class BrandRepositoryImpl implements IBrandRepository {
  final DatabaseHelper _db;

  BrandRepositoryImpl(this._db);

  @override
  Future<List<Brand>> getAllBrands() async {
    final db = await _db.database;
    final maps = await db.query(
      'brands',
      orderBy: 'name ASC',
    );
    return maps.map((m) => BrandModel.fromMap(m)).toList();
  }

  @override
  Future<Brand?> getBrandById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'brands',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BrandModel.fromMap(maps.first);
  }

  @override
  Future<Brand> createBrand(Brand brand) async {
    final db = await _db.database;
    final model = BrandModel.fromEntity(brand);
    final id = await db.insert(
      'brands',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return brand.copyWith(id: id);
  }

  @override
  Future<Brand> updateBrand(Brand brand) async {
    final db = await _db.database;
    final model = BrandModel.fromEntity(brand);
    await db.update(
      'brands',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [brand.id],
    );
    return brand;
  }

  @override
  Future<void> deleteBrand(int id) async {
    final db = await _db.database;
    // Soft unlink: SET NULL on products.brand_id handled by FK ON DELETE SET NULL
    await db.delete('brands', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> getProductCountForBrand(int brandId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE brand_id = ?',
      [brandId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  @override
  Future<bool> brandNameExists(String name, {int? excludeId}) async {
    final db = await _db.database;
    String where = 'name = ? COLLATE NOCASE';
    List<dynamic> args = [name];
    if (excludeId != null) {
      where += ' AND id != ?';
      args.add(excludeId);
    }
    final result = await db.query(
      'brands',
      where: where,
      whereArgs: args,
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
