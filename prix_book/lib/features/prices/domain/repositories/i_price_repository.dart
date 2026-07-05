import '../entities/price_record.dart';

abstract class IPriceRepository {
  /// Append-only — never updates existing records (BR-PR03)
  Future<PriceRecord> addPriceRecord(PriceRecord record);

  /// Latest price per (product, supplier) pair sorted cheapest first
  Future<List<PriceRecord>> getLatestPricesForProduct(int productId);

  /// Full price history for a (product, supplier) pair
  Future<List<PriceRecord>> getPriceHistory(int productId, int supplierId);

  /// Latest price for a (product, supplier) pair — used for ghost text in session
  Future<PriceRecord?> getLatestPrice(int productId, int supplierId);

  /// Delete a single price record
  Future<void> deletePriceRecord(int id);

  /// Count of price records for session summary
  Future<int> getPriceCountForSession(int sessionId);

  /// All supplier names involved in a session
  Future<List<String>> getSupplierNamesForSession(int sessionId);
}
