import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/database_helper.dart';
import '../../features/brands/data/brand_repository_impl.dart';
import '../../features/brands/domain/repositories/i_brand_repository.dart';
import '../../features/brands/domain/usecases/brand_usecases.dart';
import '../../features/prices/data/price_repository_impl.dart';
import '../../features/prices/domain/repositories/i_price_repository.dart';
import '../../features/prices/domain/usecases/price_usecases.dart';
import '../../features/products/data/product_repository_impl.dart';
import '../../features/products/domain/repositories/i_product_repository.dart';
import '../../features/products/domain/usecases/product_usecases.dart';
import '../../features/sessions/data/session_repository_impl.dart';
import '../../features/sessions/domain/repositories/i_session_repository.dart';
import '../../features/sessions/domain/usecases/session_usecases.dart';
import '../../features/suppliers/data/supplier_repository_impl.dart';
import '../../features/suppliers/domain/repositories/i_supplier_repository.dart';
import '../../features/suppliers/domain/usecases/supplier_usecases.dart';

// --- Database ---
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// --- Repositories ---
final brandRepositoryProvider = Provider<IBrandRepository>((ref) {
  return BrandRepositoryImpl(ref.read(databaseHelperProvider));
});

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return ProductRepositoryImpl(ref.read(databaseHelperProvider));
});

final supplierRepositoryProvider = Provider<ISupplierRepository>((ref) {
  return SupplierRepositoryImpl(ref.read(databaseHelperProvider));
});

final priceRepositoryProvider = Provider<IPriceRepository>((ref) {
  return PriceRepositoryImpl(ref.read(databaseHelperProvider));
});

final sessionRepositoryProvider = Provider<ISessionRepository>((ref) {
  return SessionRepositoryImpl(ref.read(databaseHelperProvider));
});

// --- Brand Use Cases ---
final getAllBrandsUseCaseProvider = Provider((ref) {
  return GetAllBrandsUseCase(ref.read(brandRepositoryProvider));
});
final createBrandUseCaseProvider = Provider((ref) {
  return CreateBrandUseCase(ref.read(brandRepositoryProvider));
});
final updateBrandUseCaseProvider = Provider((ref) {
  return UpdateBrandUseCase(ref.read(brandRepositoryProvider));
});
final deleteBrandUseCaseProvider = Provider((ref) {
  return DeleteBrandUseCase(ref.read(brandRepositoryProvider));
});

// --- Product Use Cases ---
final getAllProductsUseCaseProvider = Provider((ref) {
  return GetAllProductsUseCase(ref.read(productRepositoryProvider));
});
final getProductByIdUseCaseProvider = Provider((ref) {
  return GetProductByIdUseCase(ref.read(productRepositoryProvider));
});
final createProductUseCaseProvider = Provider((ref) {
  return CreateProductUseCase(ref.read(productRepositoryProvider));
});
final updateProductUseCaseProvider = Provider((ref) {
  return UpdateProductUseCase(ref.read(productRepositoryProvider));
});
final deleteProductUseCaseProvider = Provider((ref) {
  return DeleteProductUseCase(ref.read(productRepositoryProvider));
});

// --- Supplier Use Cases ---
final getAllSuppliersUseCaseProvider = Provider((ref) {
  return GetAllSuppliersUseCase(ref.read(supplierRepositoryProvider));
});
final getSupplierByIdUseCaseProvider = Provider((ref) {
  return GetSupplierByIdUseCase(ref.read(supplierRepositoryProvider));
});
final createSupplierUseCaseProvider = Provider((ref) {
  return CreateSupplierUseCase(ref.read(supplierRepositoryProvider));
});
final updateSupplierUseCaseProvider = Provider((ref) {
  return UpdateSupplierUseCase(ref.read(supplierRepositoryProvider));
});
final deleteSupplierUseCaseProvider = Provider((ref) {
  return DeleteSupplierUseCase(ref.read(supplierRepositoryProvider));
});
final markSupplierVisitedUseCaseProvider = Provider((ref) {
  return MarkSupplierVisitedTodayUseCase(ref.read(supplierRepositoryProvider));
});

// --- Price Use Cases ---
final getLatestPricesUseCaseProvider = Provider((ref) {
  return GetLatestPricesForProductUseCase(ref.read(priceRepositoryProvider));
});
final getPriceHistoryUseCaseProvider = Provider((ref) {
  return GetPriceHistoryUseCase(ref.read(priceRepositoryProvider));
});
final getLatestPriceUseCaseProvider = Provider((ref) {
  return GetLatestPriceUseCase(ref.read(priceRepositoryProvider));
});
final addPriceRecordUseCaseProvider = Provider((ref) {
  return AddPriceRecordUseCase(ref.read(priceRepositoryProvider));
});
final deletePriceRecordUseCaseProvider = Provider((ref) {
  return DeletePriceRecordUseCase(ref.read(priceRepositoryProvider));
});

// --- Session Use Cases ---
final getActiveSessionUseCaseProvider = Provider((ref) {
  return GetActiveSessionUseCase(ref.read(sessionRepositoryProvider));
});
final startSessionUseCaseProvider = Provider((ref) {
  return StartSessionUseCase(ref.read(sessionRepositoryProvider));
});
final endSessionUseCaseProvider = Provider((ref) {
  return EndSessionUseCase(ref.read(sessionRepositoryProvider));
});
final abandonSessionUseCaseProvider = Provider((ref) {
  return AbandonSessionUseCase(ref.read(sessionRepositoryProvider));
});
