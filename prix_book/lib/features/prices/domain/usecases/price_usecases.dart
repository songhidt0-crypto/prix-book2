import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../entities/price_record.dart';
import '../repositories/i_price_repository.dart';

class GetLatestPricesForProductUseCase {
  final IPriceRepository _repo;
  GetLatestPricesForProductUseCase(this._repo);
  Future<List<PriceRecord>> call(int productId) =>
      _repo.getLatestPricesForProduct(productId);
}

class GetPriceHistoryUseCase {
  final IPriceRepository _repo;
  GetPriceHistoryUseCase(this._repo);
  Future<List<PriceRecord>> call(int productId, int supplierId) =>
      _repo.getPriceHistory(productId, supplierId);
}

class GetLatestPriceUseCase {
  final IPriceRepository _repo;
  GetLatestPriceUseCase(this._repo);
  Future<PriceRecord?> call(int productId, int supplierId) =>
      _repo.getLatestPrice(productId, supplierId);
}

class AddPriceRecordUseCase {
  final IPriceRepository _repo;
  AddPriceRecordUseCase(this._repo);

  Future<PriceRecord> call(PriceRecord record) async {
    if (record.price <= 0) {
      throw const AppException(
          message: AppStrings.errorValidPrice,
          type: AppExceptionType.validation);
    }
    if (record.price > 9999999) {
      throw const AppException(
          message: AppStrings.errorPriceRange,
          type: AppExceptionType.validation);
    }
    final now = DateTime.now();
    return _repo.addPriceRecord(
      PriceRecord(
        productId: record.productId,
        supplierId: record.supplierId,
        sessionId: record.sessionId,
        price: record.price,
        unitTypeSnapshot: record.unitTypeSnapshot,
        packSizeSnapshot: record.packSizeSnapshot,
        recordedAt: record.recordedAt,
        createdAt: now,
        supplierName: record.supplierName,
        supplierPhone: record.supplierPhone,
        productName: record.productName,
      ),
    );
  }
}

class DeletePriceRecordUseCase {
  final IPriceRepository _repo;
  DeletePriceRecordUseCase(this._repo);
  Future<void> call(int id) => _repo.deletePriceRecord(id);
}
