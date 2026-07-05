import '../domain/entities/shopping_session.dart';

class SessionModel extends ShoppingSession {
  const SessionModel({
    super.id,
    required super.startedAt,
    super.finishedAt,
    super.notes,
    required super.createdAt,
    super.pricesRecorded = 0,
    super.supplierNames = const [],
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as int?,
      startedAt: DateTime.parse(map['started_at'] as String),
      finishedAt: map['finished_at'] != null
          ? DateTime.parse(map['finished_at'] as String)
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      pricesRecorded: (map['prices_recorded'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'started_at': startedAt.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SessionModel.fromEntity(ShoppingSession session) {
    return SessionModel(
      id: session.id,
      startedAt: session.startedAt,
      finishedAt: session.finishedAt,
      notes: session.notes,
      createdAt: session.createdAt,
      pricesRecorded: session.pricesRecorded,
      supplierNames: session.supplierNames,
    );
  }
}
