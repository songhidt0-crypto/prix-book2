import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/price_record.dart';

final latestPricesProvider =
    FutureProvider.family<List<PriceRecord>, int>((ref, productId) async {
  return ref.read(getLatestPricesUseCaseProvider).call(productId);
});

final priceHistoryProvider =
    FutureProvider.family<List<PriceRecord>, ({int productId, int supplierId})>(
        (ref, args) async {
  return ref
      .read(getPriceHistoryUseCaseProvider)
      .call(args.productId, args.supplierId);
});

final latestPriceProvider =
    FutureProvider.family<PriceRecord?, ({int productId, int supplierId})>(
        (ref, args) async {
  return ref
      .read(getLatestPriceUseCaseProvider)
      .call(args.productId, args.supplierId);
});
