import '../../../core/utils/database_helper.dart';
import '../domain/entities/shopping_session.dart';
import '../domain/repositories/i_session_repository.dart';
import 'session_model.dart';

class SessionRepositoryImpl implements ISessionRepository {
  final DatabaseHelper _db;

  SessionRepositoryImpl(this._db);

  @override
  Future<ShoppingSession?> getActiveSession() async {
    final db = await _db.database;
    final maps = await db.query(
      'shopping_sessions',
      where: 'finished_at IS NULL',
      orderBy: 'started_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final session = SessionModel.fromMap(maps.first);
    return _enrichSession(session);
  }

  @override
  Future<ShoppingSession> createSession(ShoppingSession session) async {
    final db = await _db.database;
    final model = SessionModel.fromEntity(session);
    final id = await db.insert('shopping_sessions', model.toMap());
    return session.copyWith(id: id);
  }

  @override
  Future<ShoppingSession> endSession(int sessionId) async {
    final db = await _db.database;
    final now = DateTime.now();
    await db.update(
      'shopping_sessions',
      {'finished_at': now.toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    final updated = await getSessionById(sessionId);
    return updated!;
  }

  @override
  Future<void> abandonSession(int sessionId) async {
    final db = await _db.database;
    await db.delete(
        'shopping_sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  @override
  Future<List<ShoppingSession>> getAllSessions() async {
    final db = await _db.database;
    final maps = await db.query(
      'shopping_sessions',
      orderBy: 'started_at DESC',
    );
    return maps.map((m) => SessionModel.fromMap(m)).toList();
  }

  @override
  Future<ShoppingSession?> getSessionById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'shopping_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final session = SessionModel.fromMap(maps.first);
    return _enrichSession(session);
  }

  Future<ShoppingSession> _enrichSession(ShoppingSession session) async {
    if (session.id == null) return session;
    final db = await _db.database;

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM price_history WHERE session_id = ?',
      [session.id],
    );
    final pricesRecorded = (countResult.first['count'] as int?) ?? 0;

    final supplierMaps = await db.rawQuery('''
      SELECT DISTINCT s.name 
      FROM price_history ph
      JOIN suppliers s ON s.id = ph.supplier_id
      WHERE ph.session_id = ?
    ''', [session.id]);
    final supplierNames =
        supplierMaps.map((m) => m['name'] as String).toList();

    return session.copyWith(
      pricesRecorded: pricesRecorded,
      supplierNames: supplierNames,
    );
  }
}
