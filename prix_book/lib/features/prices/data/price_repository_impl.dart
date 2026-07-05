import '../../../core/utils/database_helper.dart';
import '../domain/entities/price_record.dart';
import '../domain/repositories/i_price_repository.dart';
import 'price_history_model.dart';

class PriceRepositoryImpl implements IPriceRepository {
  final DatabaseHelper _db;

  PriceRepositoryImpl(this._db);

  @override
  Future<PriceRecord> addPriceRecord(PriceRecord record) async {
    final db = await _db.database;
    final model = PriceHistoryModel.fromEntity(record);
    final id = await db.insert('price_history', model.toMap());
    return record;
  }

  @override
  Future<List<PriceRecord>> getLatestPricesForProduct(int productId) async {
    // Core comparison query from Spec Section 3.4
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT ph.*, 
             s.name as supplier_name, 
             s.phone as supplier_phone,
             CASE WHEN ph.pack_size_snapshot > 0 
                  THEN ROUND(ph.price / ph.pack_size_snapshot, 2) 
                  ELSE ph.price END AS unit_price
      FROM price_history ph
      JOIN suppliers s ON s.id = ph.supplier_id
      WHERE ph.product_id = ?
        AND ph.recorded_at = (
          SELECT MAX(ph2.recorded_at)
          FROM price_history ph2
          WHERE ph2.product_id = ph.product_id
            AND ph2.supplier_id = ph.supplier_id
        )
      ORDER BY ph.price ASC
    ''', [productId]);

    return maps.map((m) => PriceHistoryModel.fromMap(m)).toList();
  }

  @override
  Future<List<PriceRecord>> getPriceHistory(
      int productId, int supplierId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT ph.*, 
             s.name as supplier_name,
             s.phone as supplier_phone
      FROM price_history ph
      JOIN suppliers s ON s.id = ph.supplier_id
      WHERE ph.product_id = ? AND ph.supplier_id = ?
      ORDER BY ph.recorded_at DESC
    ''', [productId, supplierId]);

    return maps.map((m) => PriceHistoryModel.fromMap(m)).toList();
  }

  @override
  Future<PriceRecord?> getLatestPrice(int productId, int supplierId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT ph.*, s.name as supplier_name, s.phone as supplier_phone
      FROM price_history ph
      JOIN suppliers s ON s.id = ph.supplier_id
      WHERE ph.product_id = ? AND ph.supplier_id = ?
      ORDER BY ph.recorded_at DESC
      LIMIT 1
    ''', [productId, supplierId]);

    if (maps.isEmpty) return null;
    return PriceHistoryModel.fromMap(maps.first);
  }

  @override
  Future<void> deletePriceRecord(int id) async {
    final db = await _db.database;
    await db.delete('price_history', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> getPriceCountForSession(int sessionId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM price_history WHERE session_id = ?',
      [sessionId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  @override
  Future<List<String>> getSupplierNamesForSession(int sessionId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT s.name 
      FROM price_history ph
      JOIN suppliers s ON s.id = ph.supplier_id
      WHERE ph.session_id = ?
    ''', [sessionId]);
    return maps.map((m) => m['name'] as String).toList();
  }
}
