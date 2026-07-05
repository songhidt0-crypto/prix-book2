import 'package:sqflite/sqflite.dart';
import '../../../core/utils/database_helper.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/i_product_repository.dart';
import 'product_model.dart';

class ProductRepositoryImpl implements IProductRepository {
  final DatabaseHelper _db;

  ProductRepositoryImpl(this._db);

  @override
  Future<List<Product>> getAllProducts({
    String? searchQuery,
    int? brandId,
    String? unitType,
  }) async {
    final db = await _db.database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      conditions.add(
          '(p.name LIKE ? OR p.barcode LIKE ?)');
      final q = '%${searchQuery.trim()}%';
      args.addAll([q, q]);
    }
    if (brandId != null) {
      conditions.add('p.brand_id = ?');
      args.add(brandId);
    }
    if (unitType != null) {
      conditions.add('p.unit_type = ?');
      args.add(unitType);
    }

    final where =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    final maps = await db.rawQuery('''
      SELECT p.*, b.name as brand_name
      FROM products p
      LEFT JOIN brands b ON b.id = p.brand_id
      $where
      ORDER BY p.name ASC
    ''', args);

    return maps.map((m) => ProductModel.fromMap(m)).toList();
  }

  @override
  Future<Product?> getProductById(int id) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT p.*, b.name as brand_name
      FROM products p
      LEFT JOIN brands b ON b.id = p.brand_id
      WHERE p.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT p.*, b.name as brand_name
      FROM products p
      LEFT JOIN brands b ON b.id = p.brand_id
      WHERE p.barcode = ?
      LIMIT 1
    ''', [barcode]);
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  @override
  Future<Product> createProduct(Product product) async {
    final db = await _db.database;
    final model = ProductModel.fromEntity(product);
    final id = await db.insert(
      'products',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return product.copyWith(id: id);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final db = await _db.database;
    final model = ProductModel.fromEntity(product);
    await db.update(
      'products',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    final db = await _db.database;
    // Cascade deletes price_history due to FK
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<bool> productNameExists(String name, {int? excludeId}) async {
    final db = await _db.database;
    String where = 'name = ? COLLATE NOCASE';
    List<dynamic> args = [name];
    if (excludeId != null) {
      where += ' AND id != ?';
      args.add(excludeId);
    }
    final result = await db.query(
      'products',
      where: where,
      whereArgs: args,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  @override
  Future<bool> barcodeExists(String barcode, {int? excludeId}) async {
    final db = await _db.database;
    String where = 'barcode = ?';
    List<dynamic> args = [barcode];
    if (excludeId != null) {
      where += ' AND id != ?';
      args.add(excludeId);
    }
    final result = await db.query(
      'products',
      where: where,
      whereArgs: args,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  @override
  Future<int> getPriceCountForProduct(int productId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM price_history WHERE product_id = ?',
      [productId],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
