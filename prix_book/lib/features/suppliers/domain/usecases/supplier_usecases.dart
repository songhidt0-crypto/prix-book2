import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../entities/supplier.dart';
import '../repositories/i_supplier_repository.dart';

class GetAllSuppliersUseCase {
  final ISupplierRepository _repo;
  GetAllSuppliersUseCase(this._repo);
  Future<List<Supplier>> call({String? searchQuery}) =>
      _repo.getAllSuppliers(searchQuery: searchQuery);
}

class GetSupplierByIdUseCase {
  final ISupplierRepository _repo;
  GetSupplierByIdUseCase(this._repo);
  Future<Supplier?> call(int id) => _repo.getSupplierById(id);
}

class CreateSupplierUseCase {
  final ISupplierRepository _repo;
  CreateSupplierUseCase(this._repo);

  Future<Supplier> call(Supplier supplier) async {
    if (supplier.name.trim().isEmpty) {
      throw const AppException(
          message: AppStrings.errorRequired,
          type: AppExceptionType.validation);
    }
    final exists = await _repo.supplierNameExists(supplier.name.trim());
    if (exists) {
      throw const AppException(
          message: AppStrings.errorSupplierNameExists,
          type: AppExceptionType.dbConstraint);
    }
    if (supplier.lastVisitDate != null &&
        supplier.lastVisitDate!.isAfter(DateTime.now())) {
      throw const AppException(
          message: AppStrings.errorFutureDate,
          type: AppExceptionType.validation);
    }
    final now = DateTime.now();
    return _repo.createSupplier(supplier.copyWith(
      name: supplier.name.trim(),
      createdAt: now,
      updatedAt: now,
    ));
  }
}

class UpdateSupplierUseCase {
  final ISupplierRepository _repo;
  UpdateSupplierUseCase(this._repo);

  Future<Supplier> call(Supplier supplier) async {
    if (supplier.name.trim().isEmpty) {
      throw const AppException(
          message: AppStrings.errorRequired,
          type: AppExceptionType.validation);
    }
    final exists = await _repo.supplierNameExists(
        supplier.name.trim(),
        excludeId: supplier.id);
    if (exists) {
      throw const AppException(
          message: AppStrings.errorSupplierNameExists,
          type: AppExceptionType.dbConstraint);
    }
    if (supplier.lastVisitDate != null &&
        supplier.lastVisitDate!.isAfter(DateTime.now())) {
      throw const AppException(
          message: AppStrings.errorFutureDate,
          type: AppExceptionType.validation);
    }
    return _repo.updateSupplier(supplier.copyWith(
      name: supplier.name.trim(),
      updatedAt: DateTime.now(),
    ));
  }
}

class DeleteSupplierUseCase {
  final ISupplierRepository _repo;
  DeleteSupplierUseCase(this._repo);

  Future<int> getPriceCount(int supplierId) =>
      _repo.getPriceCountForSupplier(supplierId);

  Future<void> call(int supplierId) => _repo.deleteSupplier(supplierId);
}

class MarkSupplierVisitedTodayUseCase {
  final ISupplierRepository _repo;
  MarkSupplierVisitedTodayUseCase(this._repo);
  Future<Supplier> call(int supplierId) => _repo.markVisitedToday(supplierId);
}
