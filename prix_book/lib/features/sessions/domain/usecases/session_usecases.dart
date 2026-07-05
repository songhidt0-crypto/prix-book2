import '../../../../core/errors/failures.dart';
import '../entities/shopping_session.dart';
import '../repositories/i_session_repository.dart';

class GetActiveSessionUseCase {
  final ISessionRepository _repo;
  GetActiveSessionUseCase(this._repo);
  Future<ShoppingSession?> call() => _repo.getActiveSession();
}

class StartSessionUseCase {
  final ISessionRepository _repo;
  StartSessionUseCase(this._repo);

  Future<ShoppingSession> call() async {
    // Check for existing active session (BR-SS01)
    final active = await _repo.getActiveSession();
    if (active != null) {
      throw AppException(
        message:
            'لديك جلسة نشطة. أنهِها قبل البدء بجلسة جديدة.',
        type: AppExceptionType.validation,
      );
    }
    final now = DateTime.now();
    return _repo.createSession(ShoppingSession(
      startedAt: now,
      createdAt: now,
    ));
  }
}

class EndSessionUseCase {
  final ISessionRepository _repo;
  EndSessionUseCase(this._repo);
  Future<ShoppingSession> call(int sessionId) =>
      _repo.endSession(sessionId);
}

class AbandonSessionUseCase {
  final ISessionRepository _repo;
  AbandonSessionUseCase(this._repo);
  Future<void> call(int sessionId) => _repo.abandonSession(sessionId);
}
