import 'package:equatable/equatable.dart';

/// Brand domain entity
/// Spec Section 3.2 — brands table
class Brand extends Equatable {
  final int? id;
  final String name;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Brand({
    this.id,
    required this.name,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Brand copyWith({
    int? id,
    String? name,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, notes, createdAt, updatedAt];
}
