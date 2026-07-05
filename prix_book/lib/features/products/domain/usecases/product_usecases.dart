import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/unit_types.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/i_product_repository.dart';

class GetAllProductsUseCase {
  final IProductRepository _repo;
  GetAllProductsUseCase(this._repo);

  Future<List<Product>> call({
    String? searchQuery,
    int? brandId,
    UnitType? unitType,
  }) =>
      _repo.getAllProducts(
        searchQuery: searchQuery,
        brandId: brandId,
        unitType: unitType?.value,
      );
}

class GetProductByIdUseCase {
  final IProductRepository _repo;
  GetProductByIdUseCase(this._repo);
  Future<Product?> call(int id) => _repo.getProductById(id);
}

class CreateProductUseCase {
  final IProductRepository _repo;
  CreateProductUseCase(this._repo);

  Future<Product> call(Product product) async {
    if (product.name.trim().isEmpty) {
      throw const AppException(
          message: AppStrings.errorRequired,
          type: AppExceptionType.validation);
    }
    if (product.name.trim().length > 100) {
      throw const AppException(
          message: AppStrings.errorProductNameMax,
          type: AppExceptionType.validation);
    }
    final nameExists = await _repo.productNameExists(product.name.trim());
    if (nameExists) {
      throw const AppException(
          message: AppStrings.errorProductNameExists,
          type: AppExceptionType.dbConstraint);
    }
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      final barcodeExists = await _repo.barcodeExists(product.barcode!);
      if (barcodeExists) {
        throw const AppException(
            message: AppStrings.errorBarcodeExists,
            type: AppExceptionType.dbConstraint);
      }
    }
    if (product.packSize != null && product.packSize! <= 0) {
      throw const AppException(
          message: AppStrings.errorPackSizePositive,
          type: AppExceptionType.validation);
    }

    final now = DateTime.now();
    return _repo.createProduct(product.copyWith(
      name: product.name.trim(),
      createdAt: now,
      updatedAt: now,
    ));
  }
}

class UpdateProductUseCase {
  final IProductRepository _repo;
  UpdateProductUseCase(this._repo);

  Future<Product> call(Product product) async {
    if (product.name.trim().isEmpty) {
      throw const AppException(
          message: AppStrings.errorRequired,
          type: AppExceptionType.validation);
    }
    if (product.name.trim().length > 100) {
      throw const AppException(
          message: AppStrings.errorProductNameMax,
          type: AppExceptionType.validation);
    }
    final nameExists =
        await _repo.productNameExists(product.name.trim(), excludeId: product.id);
    if (nameExists) {
      throw const AppException(
          message: AppStrings.errorProductNameExists,
          type: AppExceptionType.dbConstraint);
    }
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      final barcodeExists =
          await _repo.barcodeExists(product.barcode!, excludeId: product.id);
      if (barcodeExists) {
        throw const AppException(
            message: AppStrings.errorBarcodeExists,
            type: AppExceptionType.dbConstraint);
      }
    }
    if (product.packSize != null && product.packSize! <= 0) {
      throw const AppException(
          message: AppStrings.errorPackSizePositive,
          type: AppExceptionType.validation);
    }
    return _repo.updateProduct(product.copyWith(
      name: product.name.trim(),
      updatedAt: DateTime.now(),
    ));
  }
}

class DeleteProductUseCase {
  final IProductRepository _repo;
  DeleteProductUseCase(this._repo);

  Future<int> getPriceCount(int productId) =>
      _repo.getPriceCountForProduct(productId);

  Future<void> call(int productId) => _repo.deleteProduct(productId);
}
