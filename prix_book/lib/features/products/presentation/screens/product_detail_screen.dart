import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/dzd_formatter.dart';
import '../../../../shared/widgets/confirm_delete_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/price_age_dot.dart';
import '../../../prices/domain/entities/price_record.dart';
import '../../../prices/presentation/providers/price_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return productAsync.when(
      loading: () => const Scaffold(
          body: Center(child: const CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          body: Center(child: Text(AppStrings.errorGeneric))),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text(AppStrings.errorGeneric)),
          );
        }
        return _ProductDetailView(product: product);
      },
    );
  }
}

class _ProductDetailView extends ConsumerWidget {
  final Product product;

  const _ProductDetailView({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricesAsync = ref.watch(latestPricesProvider(product.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: AppStrings.editProduct,
            onPressed: () => context.push('/products/${product.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppStrings.deleteProduct,
            onPressed: () async {
              final count = await ref
                  .read(productsProvider.notifier)
                  .getPriceCount(product.id!);
              if (!context.mounted) return;
              ConfirmDeleteDialog.show(
                context,
                title: AppStrings.deleteProduct,
                message: count > 0
                    ? '${AppStrings.thisWillDelete} $count ${AppStrings.priceRecords}.\n${AppStrings.deleteProductConfirm}'
                    : AppStrings.deleteProductConfirm,
                onConfirm: () {
                  ref
                      .read(productsProvider.notifier)
                      .deleteProduct(product.id!);
                  context.pop();
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _ProductHeader(product: product),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              AppStrings.priceComparison,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          pricesAsync.when(
            loading: () =>
                const Center(child: const CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(AppStrings.errorGeneric)),
            data: (prices) {
              if (prices.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.price_change_outlined,
                  title: AppStrings.noPricesYet,
                  subtitle: AppStrings.noPricesSubtitle,
                );
              }
              return _PriceComparisonList(
                  prices: prices, product: product);
            },
          ),
        ],
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final Product product;

  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (product.brandName != null) ...[
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(product.brandName!),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                const SizedBox(height: 8),
                _InfoRow(
                    label: AppStrings.unitType,
                    value: product.unitType.arabicLabel),
                if (product.packSize != null)
                  _InfoRow(
                      label: AppStrings.packSize,
                      value: '${product.packSize}'),
                if (product.barcode != null)
                  _InfoRow(
                      label: AppStrings.barcode, value: product.barcode!),
                if (product.notes != null && product.notes!.isNotEmpty)
                  _InfoRow(label: AppStrings.notes, value: product.notes!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.altRow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Icon(Icons.inventory_2_outlined,
          size: 40, color: AppColors.primaryNavy),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceComparisonList extends StatelessWidget {
  final List<PriceRecord> prices;
  final Product product;

  const _PriceComparisonList(
      {required this.prices, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasPackSizeDiff = prices.any((p) =>
        p.packSizeSnapshot != null && p.packSizeSnapshot != product.packSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasPackSizeDiff)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              AppStrings.unitPriceNote,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ...prices.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          final isBest = index == 0;
          return _PriceCard(
            record: record,
            isBest: isBest,
            rank: index + 1,
            onTap: () => context.push(
              '/suppliers/${record.supplierId}',
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Price comparison card per Spec Section 4.3
class _PriceCard extends StatelessWidget {
  final PriceRecord record;
  final bool isBest;
  final int rank;
  final VoidCallback onTap;

  const _PriceCard({
    required this.record,
    required this.isBest,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isBest ? AppColors.bestPriceBackground : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isBest ? AppColors.emeraldGreen : Colors.transparent,
            width: 4,
          ),
          top: BorderSide(color: AppColors.cardBorder, width: 0.5),
          right: BorderSide(color: AppColors.cardBorder, width: 0.5),
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isBest
                      ? AppColors.emeraldGreen
                      : AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.supplierName ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (isBest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              AppStrings.bestPrice,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        PriceAgeDot(recordedAt: record.recordedAt),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.priceAgeLabel(record.recordedAt),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DZDFormatter.format(record.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isBest
                              ? AppColors.emeraldGreen
                              : AppColors.textDark,
                        ),
                  ),
                  if (record.unitPrice != null)
                    Text(
                      '= ${DZDFormatter.formatNumber(record.unitPrice!)} ${AppStrings.dzd}/${AppStrings.unitPiece}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
