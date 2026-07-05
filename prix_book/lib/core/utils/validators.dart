import '../constants/app_strings.dart';

/// Input validators as per BR rules in Section 6
class Validators {
  /// Product name: required, max 100 chars
  static String? productName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    if (value.trim().length > 100) {
      return AppStrings.errorProductNameMax;
    }
    return null;
  }

  /// Brand name: required, no length limit specified
  static String? brandName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    return null;
  }

  /// Supplier name: required
  static String? supplierName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    return null;
  }

  /// Pack size: must be > 0 if provided
  static String? packSize(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final n = int.tryParse(value.trim());
    if (n == null || n <= 0) {
      return AppStrings.errorPackSizePositive;
    }
    return null;
  }

  /// Price: required, > 0, <= 9_999_999
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorValidPrice;
    }
    final n = double.tryParse(value.trim().replaceAll(' ', ''));
    if (n == null || n <= 0) {
      return AppStrings.errorValidPrice;
    }
    if (n > 9999999) {
      return AppStrings.errorPriceRange;
    }
    return null;
  }

  /// Phone: digits only, optionally prefixed with + or 0 (BR-S04)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final cleaned = value.trim();
    final regex = RegExp(r'^\+?0?\d{7,15}$');
    if (!regex.hasMatch(cleaned)) {
      return AppStrings.errorValidPhone;
    }
    return null;
  }

  /// Last visit date: must not be in the future (BR-S05)
  static String? lastVisitDate(DateTime? value) {
    if (value == null) return null;
    if (value.isAfter(DateTime.now())) {
      return AppStrings.errorFutureDate;
    }
    return null;
  }
}
