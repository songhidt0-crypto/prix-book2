import '../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    super.id,
    required super.name,
    super.phone,
    super.address,
    super.notes,
    super.lastVisitDate,
    required super.createdAt,
    required super.updatedAt,
    super.priceCount = 0,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      lastVisitDate: map['last_visit_date'] != null
          ? DateTime.parse(map['last_visit_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      priceCount: (map['price_count'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'last_visit_date': lastVisitDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SupplierModel.fromEntity(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      name: supplier.name,
      phone: supplier.phone,
      address: supplier.address,
      notes: supplier.notes,
      lastVisitDate: supplier.lastVisitDate,
      createdAt: supplier.createdAt,
      updatedAt: supplier.updatedAt,
      priceCount: supplier.priceCount,
    );
  }
}
