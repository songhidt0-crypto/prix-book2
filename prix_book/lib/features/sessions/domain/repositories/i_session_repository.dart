import '../entities/shopping_session.dart';

abstract class ISessionRepository {
  Future<ShoppingSession?> getActiveSession();
  Future<ShoppingSession> createSession(ShoppingSession session);
  Future<ShoppingSession> endSession(int sessionId);
  Future<void> abandonSession(int sessionId);
  Future<List<ShoppingSession>> getAllSessions();
  Future<ShoppingSession?> getSessionById(int id);
}
