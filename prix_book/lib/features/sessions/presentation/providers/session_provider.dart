import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../prices/domain/entities/price_record.dart';
import '../../../sessions/domain/entities/shopping_session.dart';
import '../../../suppliers/domain/entities/supplier.dart';

/// Session state machine as per Spec Section 5.1 & 6.5
class SessionState {
  final ShoppingSession? activeSession;
  final Supplier? currentSupplier;
  final int pricesRecordedCount;
  final bool isLoading;
  final String? error;
  /// Products that got a checkmark this session (product_id set)
  final Set<int> savedProductIds;

  const SessionState({
    this.activeSession,
    this.currentSupplier,
    this.pricesRecordedCount = 0,
    this.isLoading = false,
    this.error,
    this.savedProductIds = const {},
  });

  bool get isActive => activeSession != null;

  SessionState copyWith({
    ShoppingSession? activeSession,
    Supplier? currentSupplier,
    int? pricesRecordedCount,
    bool? isLoading,
    String? error,
    Set<int>? savedProductIds,
    bool clearSession = false,
    bool clearSupplier = false,
  }) {
    return SessionState(
      activeSession:
          clearSession ? null : (activeSession ?? this.activeSession),
      currentSupplier:
          clearSupplier ? null : (currentSupplier ?? this.currentSupplier),
      pricesRecordedCount:
          pricesRecordedCount ?? this.pricesRecordedCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedProductIds: savedProductIds ?? this.savedProductIds,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref _ref;

  SessionNotifier(this._ref) : super(const SessionState()) {
    _restoreActiveSession();
  }

  /// On app launch, restore any active session (BR-SS02)
  Future<void> _restoreActiveSession() async {
    final session =
        await _ref.read(getActiveSessionUseCaseProvider).call();
    if (session != null) {
      state = state.copyWith(
        activeSession: session,
        pricesRecordedCount: session.pricesRecorded,
      );
    }
  }

  Future<void> startSession(Supplier supplier) async {
    state = state.copyWith(isLoading: true);
    try {
      final session =
          await _ref.read(startSessionUseCaseProvider).call();
      state = SessionState(
        activeSession: session,
        currentSupplier: supplier,
        pricesRecordedCount: 0,
        savedProductIds: {},
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void switchSupplier(Supplier supplier) {
    state = state.copyWith(currentSupplier: supplier);
  }

  /// Record a price during session (BR-SS03)
  Future<void> recordPrice({
    required int productId,
    required double price,
    required PriceRecord record,
  }) async {
    if (state.activeSession == null || state.currentSupplier == null) return;

    await _ref.read(addPriceRecordUseCaseProvider).call(record);

    final newSaved = Set<int>.from(state.savedProductIds)..add(productId);
    state = state.copyWith(
      pricesRecordedCount: state.pricesRecordedCount + 1,
      savedProductIds: newSaved,
    );
  }

  /// End session — mark visited today for all suppliers (BR-SS05)
  Future<ShoppingSession?> endSession() async {
    if (state.activeSession?.id == null) return null;

    final session = await _ref
        .read(endSessionUseCaseProvider)
        .call(state.activeSession!.id!);

    // Mark all suppliers visited today
    await _markSuppliersVisited(session.id!);

    final enriched = session.copyWith(
      pricesRecorded: state.pricesRecordedCount,
      supplierNames: session.supplierNames,
    );

    // Reset state
    state = const SessionState();

    return enriched;
  }

  /// Abandon session if no prices recorded (BR-SS04)
  Future<void> abandonSession() async {
    if (state.activeSession?.id == null) return;
    if (state.pricesRecordedCount == 0) {
      await _ref
          .read(abandonSessionUseCaseProvider)
          .call(state.activeSession!.id!);
    } else {
      // End it properly
      await endSession();
    }
    state = const SessionState();
  }

  Future<void> _markSuppliersVisited(int sessionId) async {
    try {
      final db = _ref.read(databaseHelperProvider);
      final database = await db.database;
      final maps = await database.rawQuery('''
        SELECT DISTINCT supplier_id FROM price_history WHERE session_id = ?
      ''', [sessionId]);
      for (final row in maps) {
        final supplierId = row['supplier_id'] as int;
        await _ref
            .read(markSupplierVisitedUseCaseProvider)
            .call(supplierId);
      }
    } catch (_) {}
  }

  Future<String> getActiveSessionConflictMessage() async {
    return AppStrings.activeSessionWarning;
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref);
});
