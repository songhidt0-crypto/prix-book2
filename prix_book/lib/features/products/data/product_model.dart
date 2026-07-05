import '../../../core/constants/unit_types.dart';
import '../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.name,
    super.brandId,
    super.brandName,
    required super.unitType,
    super.packSize,
    super.barcode,
    super.imagePath,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      brandId: map['brand_id'] as int?,
      brandName: map['brand_name'] as String?,
      unitType: UnitType.fromValue(map['unit_type'] as String? ?? 'Piece'),
      packSize: map['pack_size'] as int?,
      barcode: map['barcode'] as String?,
      imagePath: map['image_path'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'brand_id': brandId,
      'unit_type': unitType.value,
      'pack_size': packSize,
      'barcode': barcode,
      'image_path': imagePath,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      brandId: product.brandId,
      brandName: product.brandName,
      unitType: product.unitType,
      packSize: product.packSize,
      barcode: product.barcode,
      imagePath: product.imagePath,
      notes: product.notes,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
