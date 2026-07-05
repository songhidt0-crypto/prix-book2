import 'package:equatable/equatable.dart';
import '../../../../core/constants/unit_types.dart';

/// Product domain entity
/// Spec Section 3.2 — products table
class Product extends Equatable {
  final int? id;
  final String name;
  final int? brandId;
  final String? brandName; // denormalized for display
  final UnitType unitType;
  final int? packSize;
  final String? barcode;
  final String? imagePath;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    this.id,
    required this.name,
    this.brandId,
    this.brandName,
    required this.unitType,
    this.packSize,
    this.barcode,
    this.imagePath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    int? id,
    String? name,
    int? brandId,
    String? brandName,
    UnitType? unitType,
    int? packSize,
    String? barcode,
    String? imagePath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearBrandId = false,
    bool clearPackSize = false,
    bool clearBarcode = false,
    bool clearImagePath = false,
    bool clearBrandName = false,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brandId: clearBrandId ? null : (brandId ?? this.brandId),
      brandName: clearBrandName ? null : (brandName ?? this.brandName),
      unitType: unitType ?? this.unitType,
      packSize: clearPackSize ? null : (packSize ?? this.packSize),
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        brandId,
        unitType,
        packSize,
        barcode,
        imagePath,
        notes,
        createdAt,
        updatedAt,
      ];
}
