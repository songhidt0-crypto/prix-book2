import '../entities/product.dart';

abstract class IProductRepository {
  Future<List<Product>> getAllProducts({String? searchQuery, int? brandId, String? unitType});
  Future<Product?> getProductById(int id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<bool> productNameExists(String name, {int? excludeId});
  Future<bool> barcodeExists(String barcode, {int? excludeId});
  Future<int> getPriceCountForProduct(int productId);
}
