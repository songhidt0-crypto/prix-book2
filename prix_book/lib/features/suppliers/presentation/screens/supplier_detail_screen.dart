import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/dzd_formatter.dart';
import '../../../../shared/widgets/confirm_delete_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/price_age_dot.dart';
import '../../../prices/presentation/providers/price_provider.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../domain/entities/supplier.dart';
import '../providers/suppliers_provider.dart';

class SupplierDetailScreen extends ConsumerWidget {
  final int supplierId;
  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(supplierDetailProvider(supplierId));

    return supplierAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: const CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text(AppStrings.errorGeneric))),
      data: (supplier) {
        if (supplier == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text(AppStrings.errorGeneric)),
          );
        }
        return _SupplierDetailView(supplier: supplier);
      },
    );
  }
}

class _SupplierDetailView extends ConsumerWidget {
  final Supplier supplier;
  const _SupplierDetailView({required this.supplier});

  Future<void> _callPhone(BuildContext context) async {
    if (!supplier.hasPhone) return;
    final uri = Uri.parse('tel:${supplier.phone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(supplier.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.push('/suppliers/${supplier.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final count = await ref
                  .read(suppliersProvider.notifier)
                  .getPriceCount(supplier.id!);
              if (!context.mounted) return;
              ConfirmDeleteDialog.show(
                context,
                title: AppStrings.deleteSupplier,
                message: count > 0
                    ? '${AppStrings.thisWillDelete} $count ${AppStrings.priceRecords}.\n${AppStrings.deleteSupplierConfirm}'
                    : AppStrings.deleteSupplierConfirm,
                onConfirm: () {
                  ref
                      .read(suppliersProvider.notifier)
                      .deleteSupplier(supplier.id!);
                  context.pop();
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _SupplierInfoCard(
              supplier: supplier, onCall: () => _callPhone(context)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              AppStrings.priceHistory,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          _SupplierPriceList(supplier: supplier),
        ],
      ),
    );
  }
}

class _SupplierInfoCard extends ConsumerWidget {
  final Supplier supplier;
  final VoidCallback onCall;
  const _SupplierInfoCard(
      {required this.supplier, required this.onCall});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.hasPhone)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined,
                    color: AppColors.primaryNavy),
                title: Text(supplier.phone!),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: AppColors.emeraldGreen),
                  onPressed: onCall,
                ),
              ),
            if (supplier.address != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on_outlined,
                    color: AppColors.primaryNavy),
                title: Text(supplier.address!),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.primaryNavy),
              title: Text(
                supplier.lastVisitDate != null
                    ? '${AppStrings.lastVisit}: ${DateFormatter.formatDate(supplier.lastVisitDate!)}'
                    : AppStrings.neverVisited,
              ),
              trailing: OutlinedButton(
                onPressed: () => ref
                    .read(suppliersProvider.notifier)
                    .markVisitedToday(supplier.id!),
                child: const Text(AppStrings.markVisitedToday),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierPriceList extends ConsumerWidget {
  final Supplier supplier;
  const _SupplierPriceList({required this.supplier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final products = productsState.products;

    if (products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.price_change_outlined,
        title: AppStrings.noPricesYet,
        subtitle: AppStrings.noPricesSubtitle,
      );
    }

    return Column(
      children: products
          .where((p) => p.id != null)
          .map((product) {
            return _ProductPriceRow(
                productId: product.id!,
                productName: product.name,
                supplierId: supplier.id!);
          })
          .toList(),
    );
  }
}

class _ProductPriceRow extends ConsumerWidget {
  final int productId;
  final String productName;
  final int supplierId;

  const _ProductPriceRow({
    required this.productId,
    required this.productName,
    required this.supplierId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceAsync = ref.watch(
        latestPriceProvider((productId: productId, supplierId: supplierId)));

    return priceAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (record) {
        if (record == null) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(productName,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Row(
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
            trailing: Text(
              DZDFormatter.format(record.price),
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                  fontSize: 15),
            ),
            onTap: () => context.push('/products/$productId'),
          ),
        );
      },
    );
  }
}
