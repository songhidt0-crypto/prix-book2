import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../entities/brand.dart';
import '../repositories/i_brand_repository.dart';

class GetAllBrandsUseCase {
  final IBrandRepository _repo;
  GetAllBrandsUseCase(this._repo);
  Future<List<Brand>> call() => _repo.getAllBrands();
}

class CreateBrandUseCase {
  final IBrandRepository _repo;
  CreateBrandUseCase(this._repo);

  Future<Brand> call(Brand brand) async {
    if (brand.name.trim().isEmpty) {
      throw const AppException(
          message: AppStrings.errorRequired,
          type: AppExceptionType.validation);
    }
    final exists = await _repo.brandNameExists(brand.name.trim());
    if (exists) {
      throw const AppException(
          message: AppStrings.errorBrandNameExists,
          type: AppExceptionType.dbConstraint);
    }
    final now = DateTime.now();
    return _repo.createBrand(brand.copyWith(
      name: brand.name.trim(),
      createdAt: now,
      updatedAt: now,
    ));
  }
}

class UpdateBrandUseCase {
  final IBrandRepository _repo;
  UpdateBrandUseCase(this._repo);

  Future<Brand> call(Brand brand) async {
    if (brand.name.trim().isEmpty) {
      throw const AppException(
          message: AppStrings.errorRequired,
          type: AppExceptionType.validation);
    }
    final exists =
        await _repo.brandNameExists(brand.name.trim(), excludeId: brand.id);
    if (exists) {
      throw const AppException(
          message: AppStrings.errorBrandNameExists,
          type: AppExceptionType.dbConstraint);
    }
    return _repo.updateBrand(brand.copyWith(
      name: brand.name.trim(),
      updatedAt: DateTime.now(),
    ));
  }
}

class DeleteBrandUseCase {
  final IBrandRepository _repo;
  DeleteBrandUseCase(this._repo);

  Future<int> getProductCount(int brandId) =>
      _repo.getProductCountForBrand(brandId);

  Future<void> call(int brandId) => _repo.deleteBrand(brandId);
}
