import 'app_strings.dart';

/// Unit types as defined in Prix Book Master Spec v1.1 Section 3.2
enum UnitType {
  piece,
  box,
  carton,
  pack,
  other;

  String get value {
    switch (this) {
      case UnitType.piece:
        return 'Piece';
      case UnitType.box:
        return 'Box';
      case UnitType.carton:
        return 'Carton';
      case UnitType.pack:
        return 'Pack';
      case UnitType.other:
        return 'Other';
    }
  }

  String get arabicLabel {
    switch (this) {
      case UnitType.piece:
        return AppStrings.unitPiece;
      case UnitType.box:
        return AppStrings.unitBox;
      case UnitType.carton:
        return AppStrings.unitCarton;
      case UnitType.pack:
        return AppStrings.unitPack;
      case UnitType.other:
        return AppStrings.unitOther;
    }
  }

  static UnitType fromValue(String value) {
    return UnitType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UnitType.piece,
    );
  }
}
