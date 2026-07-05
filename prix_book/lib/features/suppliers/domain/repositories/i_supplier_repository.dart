import '../entities/supplier.dart';

abstract class ISupplierRepository {
  Future<List<Supplier>> getAllSuppliers({String? searchQuery});
  Future<Supplier?> getSupplierById(int id);
  Future<Supplier> createSupplier(Supplier supplier);
  Future<Supplier> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(int id);
  Future<bool> supplierNameExists(String name, {int? excludeId});
  Future<Supplier> markVisitedToday(int supplierId);
  Future<int> getPriceCountForSupplier(int supplierId);
}
