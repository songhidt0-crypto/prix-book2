import '../../../core/constants/unit_types.dart';
import '../domain/entities/price_record.dart';

class PriceHistoryModel extends PriceRecord {
  const PriceHistoryModel({
    super.id,
    required super.productId,
    required super.supplierId,
    super.sessionId,
    required super.price,
    required super.unitTypeSnapshot,
    super.packSizeSnapshot,
    required super.recordedAt,
    required super.createdAt,
    super.supplierName,
    super.supplierPhone,
    super.productName,
  });

  factory PriceHistoryModel.fromMap(Map<String, dynamic> map) {
    return PriceHistoryModel(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      supplierId: map['supplier_id'] as int,
      sessionId: map['session_id'] as int?,
      price: (map['price'] as num).toDouble(),
      unitTypeSnapshot: UnitType.fromValue(
        map['unit_type_snapshot'] as String? ?? 'Piece',
      ),
      packSizeSnapshot: map['pack_size_snapshot'] as int?,
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      supplierName: map['supplier_name'] as String?,
      supplierPhone: map['supplier_phone'] as String?,
      productName: map['product_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'supplier_id': supplierId,
      'session_id': sessionId,
      'price': price,
      'unit_type_snapshot': unitTypeSnapshot.value,
      'pack_size_snapshot': packSizeSnapshot,
      'recorded_at': recordedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PriceHistoryModel.fromEntity(PriceRecord record) {
    return PriceHistoryModel(
      id: record.id,
      productId: record.productId,
      supplierId: record.supplierId,
      sessionId: record.sessionId,
      price: record.price,
      unitTypeSnapshot: record.unitTypeSnapshot,
      packSizeSnapshot: record.packSizeSnapshot,
      recordedAt: record.recordedAt,
      createdAt: record.createdAt,
      supplierName: record.supplierName,
      supplierPhone: record.supplierPhone,
      productName: record.productName,
    );
  }
}
