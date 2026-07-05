import 'package:equatable/equatable.dart';

/// Supplier domain entity
/// Spec Section 3.2 — suppliers table
class Supplier extends Equatable {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime? lastVisitDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed fields (populated by queries, not stored)
  final int priceCount;

  const Supplier({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    this.lastVisitDate,
    required this.createdAt,
    required this.updatedAt,
    this.priceCount = 0,
  });

  Supplier copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    DateTime? lastVisitDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? priceCount,
    bool clearPhone = false,
    bool clearAddress = false,
    bool clearNotes = false,
    bool clearLastVisit = false,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: clearPhone ? null : (phone ?? this.phone),
      address: clearAddress ? null : (address ?? this.address),
      notes: clearNotes ? null : (notes ?? this.notes),
      lastVisitDate:
          clearLastVisit ? null : (lastVisitDate ?? this.lastVisitDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priceCount: priceCount ?? this.priceCount,
    );
  }

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        address,
        notes,
        lastVisitDate,
        createdAt,
        updatedAt,
      ];
}
