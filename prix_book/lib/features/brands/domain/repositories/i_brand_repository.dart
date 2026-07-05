import '../entities/brand.dart';

abstract class IBrandRepository {
  Future<List<Brand>> getAllBrands();
  Future<Brand?> getBrandById(int id);
  Future<Brand> createBrand(Brand brand);
  Future<Brand> updateBrand(Brand brand);
  Future<void> deleteBrand(int id);
  Future<int> getProductCountForBrand(int brandId);
  Future<bool> brandNameExists(String name, {int? excludeId});
}
