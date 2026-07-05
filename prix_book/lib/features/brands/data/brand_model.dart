import '../domain/entities/brand.dart';

class BrandModel extends Brand {
  const BrandModel({
    super.id,
    required super.name,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BrandModel.fromEntity(Brand brand) {
    return BrandModel(
      id: brand.id,
      name: brand.name,
      notes: brand.notes,
      createdAt: brand.createdAt,
      updatedAt: brand.updatedAt,
    );
  }
}
