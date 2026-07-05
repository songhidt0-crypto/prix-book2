import 'package:equatable/equatable.dart';
import '../../../../core/constants/unit_types.dart';

/// Price history record — append-only, never overwritten
/// Spec Section 3.2 — price_history table, Section 6.4
class PriceRecord extends Equatable {
  final int? id;
  final int productId;
  final int supplierId;
  final int? sessionId;
  final double price;
  final UnitType unitTypeSnapshot;
  final int? packSizeSnapshot;
  final DateTime recordedAt;
  final DateTime createdAt;

  // Denormalized for display
  final String? supplierName;
  final String? supplierPhone;
  final String? productName;

  const PriceRecord({
    this.id,
    required this.productId,
    required this.supplierId,
    this.sessionId,
    required this.price,
    required this.unitTypeSnapshot,
    this.packSizeSnapshot,
    required this.recordedAt,
    required this.createdAt,
    this.supplierName,
    this.supplierPhone,
    this.productName,
  });

  /// Unit price (price / packSize) for pack comparison
  double? get unitPrice {
    if (packSizeSnapshot == null || packSizeSnapshot! <= 0) return null;
    return price / packSizeSnapshot!;
  }

  /// Comparison price — uses unit price if pack size available (BR-C04)
  double get comparisonPrice => unitPrice ?? price;

  @override
  List<Object?> get props => [
        id,
        productId,
        supplierId,
        sessionId,
        price,
        unitTypeSnapshot,
        packSizeSnapshot,
        recordedAt,
        createdAt,
      ];
}
