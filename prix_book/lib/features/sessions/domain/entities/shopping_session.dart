import 'package:equatable/equatable.dart';

/// Shopping session domain entity
/// Spec Section 3.2 — shopping_sessions table, Section 6.5
class ShoppingSession extends Equatable {
  final int? id;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? notes;
  final DateTime createdAt;

  // Runtime computed
  final int pricesRecorded;
  final List<String> supplierNames;

  const ShoppingSession({
    this.id,
    required this.startedAt,
    this.finishedAt,
    this.notes,
    required this.createdAt,
    this.pricesRecorded = 0,
    this.supplierNames = const [],
  });

  bool get isActive => finishedAt == null;

  Duration get duration {
    final end = finishedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  ShoppingSession copyWith({
    int? id,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? notes,
    DateTime? createdAt,
    int? pricesRecorded,
    List<String>? supplierNames,
    bool clearFinishedAt = false,
  }) {
    return ShoppingSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      pricesRecorded: pricesRecorded ?? this.pricesRecorded,
      supplierNames: supplierNames ?? this.supplierNames,
    );
  }

  @override
  List<Object?> get props => [id, startedAt, finishedAt, notes, createdAt];
}
