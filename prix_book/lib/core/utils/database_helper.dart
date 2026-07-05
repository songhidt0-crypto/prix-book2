import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

/// SQLite database helper implementing schema v1.1
/// as defined in Prix Book Master Spec v1.1 Section 3.2 & 3.3
class DatabaseHelper {
  static const String _dbName = 'prix_book.db';
  static const int _dbVersion = 1;

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, _dbName);

    return await openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // --- brands table ---
    await db.execute('''
      CREATE TABLE brands (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // --- products table ---
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE,
        brand_id INTEGER REFERENCES brands(id) ON DELETE SET NULL,
        unit_type TEXT NOT NULL DEFAULT 'Piece',
        pack_size INTEGER CHECK(pack_size > 0),
        barcode TEXT UNIQUE,
        image_path TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // --- suppliers table ---
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE,
        phone TEXT,
        address TEXT,
        notes TEXT,
        last_visit_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // --- shopping_sessions table ---
    await db.execute('''
      CREATE TABLE shopping_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        started_at TEXT NOT NULL,
        finished_at TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // --- price_history table ---
    await db.execute('''
      CREATE TABLE price_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
        supplier_id INTEGER NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
        session_id INTEGER REFERENCES shopping_sessions(id) ON DELETE SET NULL,
        price REAL NOT NULL CHECK(price > 0),
        unit_type_snapshot TEXT NOT NULL,
        pack_size_snapshot INTEGER,
        recorded_at TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // --- Indexes (Section 3.3) ---
    await db.execute(
        'CREATE INDEX idx_products_name ON products(name)');
    await db.execute(
        'CREATE INDEX idx_products_brand ON products(brand_id)');
    await db.execute(
        'CREATE INDEX idx_products_barcode ON products(barcode)');
    await db.execute(
        'CREATE INDEX idx_suppliers_name ON suppliers(name)');
    await db.execute(
        'CREATE INDEX idx_price_history_product ON price_history(product_id)');
    await db.execute(
        'CREATE INDEX idx_price_history_supplier ON price_history(supplier_id)');
    await db.execute(
        'CREATE INDEX idx_price_history_session ON price_history(session_id)');
    await db.execute(
        'CREATE INDEX idx_price_history_recorded ON price_history(recorded_at DESC)');
    await db.execute('''
      CREATE INDEX idx_price_history_composite 
      ON price_history(product_id, supplier_id, recorded_at DESC)
    ''');
  }

  /// Get the database file path for backup export
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return path.join(dbPath, _dbName);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
