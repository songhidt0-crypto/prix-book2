import 'package:sqflite/sqflite.dart';
import '../../../core/utils/database_helper.dart';
import '../domain/entities/supplier.dart';
import '../domain/repositories/i_supplier_repository.dart';
import 'supplier_model.dart';

class SupplierRepositoryImpl implements ISupplierRepository {
  final DatabaseHelper _db;

  SupplierRepositoryImpl(this._db);

  @override
  Future<List<Supplier>> getAllSuppliers({String? searchQuery}) async {
    final db = await _db.database;
    String where = '';
    List<dynamic> args = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      where = 'WHERE s.name LIKE ?';
      args.add('%${searchQuery.trim()}%');
    }

    final maps = await db.rawQuery('''
      SELECT s.*,
        (SELECT COUNT(DISTINCT ph.product_id) 
         FROM price_history ph 
         WHERE ph.supplier_id = s.id) as price_count
      FROM suppliers s
      $where
      ORDER BY s.name ASC
    ''', args);

    return maps.map((m) => SupplierModel.fromMap(m)).toList();
  }

  @override
  Future<Supplier?> getSupplierById(int id) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT s.*,
        (SELECT COUNT(DISTINCT ph.product_id) 
         FROM price_history ph 
         WHERE ph.supplier_id = s.id) as price_count
      FROM suppliers s
      WHERE s.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) return null;
    return SupplierModel.fromMap(maps.first);
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier) async {
    final db = await _db.database;
    final model = SupplierModel.fromEntity(supplier);
    final id = await db.insert(
      'suppliers',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return supplier.copyWith(id: id);
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    final db = await _db.database;
    final model = SupplierModel.fromEntity(supplier);
    await db.update(
      'suppliers',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
    return supplier;
  }

  @override
  Future<void> deleteSupplier(int id) async {
    final db = await _db.database;
    await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<bool> supplierNameExists(String name, {int? excludeId}) async {
    final db = await _db.database;
    String where = 'name = ? COLLATE NOCASE';
    List<dynamic> args = [name];
    if (excludeId != null) {
      where += ' AND id != ?';
      args.add(excludeId);
    }
    final result = await db.query(
      'suppliers',
      where: where,
      whereArgs: args,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  @override
  Future<Supplier> markVisitedToday(int supplierId) async {
    final db = await _db.database;
    final now = DateTime.now();
    await db.update(
      'suppliers',
      {
        'last_visit_date': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [supplierId],
    );
    final updated = await getSupplierById(supplierId);
    return updated!;
  }

  @override
  Future<int> getPriceCountForSupplier(int supplierId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM price_history WHERE supplier_id = ?',
      [supplierId],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
