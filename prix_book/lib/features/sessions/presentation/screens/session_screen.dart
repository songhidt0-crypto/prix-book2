import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/dzd_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../prices/domain/entities/price_record.dart';
import '../../../prices/presentation/providers/price_provider.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../../suppliers/presentation/providers/suppliers_provider.dart';
import '../providers/session_provider.dart';
import '../../domain/entities/shopping_session.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);

    if (!sessionState.isActive) {
      return _NoSessionView();
    }
    return _ActiveSessionView(sessionState: sessionState);
  }
}

// ─── No active session ───────────────────────────────────────────────────────
class _NoSessionView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(suppliersProvider).suppliers;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.startSession)),
      body: suppliers.isEmpty
          ? EmptyStateWidget(
              icon: Icons.store_outlined,
              title: AppStrings.suppliers,
              subtitle: AppStrings.emptySuppliers,
              action: ElevatedButton(
                onPressed: () => context.push(AppRoutes.addSupplier),
                child: const Text(AppStrings.addSupplier),
              ),
            )
          : _SelectSupplierList(
              suppliers: suppliers,
              onSelect: (s) async {
                final hasActive =
                    ref.read(sessionProvider).isActive;
                if (hasActive) {
                  _showConflictDialog(context, ref, s);
                  return;
                }
                await ref.read(sessionProvider.notifier).startSession(s);
              },
            ),
    );
  }

  void _showConflictDialog(
      BuildContext context, WidgetRef ref, Supplier supplier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.sessionActive),
        content: const Text(AppStrings.activeSessionWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(sessionProvider.notifier).abandonSession();
              await ref
                  .read(sessionProvider.notifier)
                  .startSession(supplier);
            },
            child: const Text(AppStrings.endAndStartNew,
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SelectSupplierList extends StatelessWidget {
  final List<Supplier> suppliers;
  final ValueChanged<Supplier> onSelect;

  const _SelectSupplierList(
      {required this.suppliers, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(AppStrings.selectSupplier,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, i) {
              final s = suppliers[i];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.altRow,
                  child: Icon(Icons.store_outlined,
                      color: AppColors.primaryNavy),
                ),
                title: Text(s.name),
                subtitle: s.hasPhone ? Text(s.phone!) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onSelect(s),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Active session view ──────────────────────────────────────────────────────
class _ActiveSessionView extends ConsumerWidget {
  final SessionState sessionState;

  const _ActiveSessionView({required this.sessionState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplier = sessionState.currentSupplier;
    final products = ref.watch(productsProvider).products;

    return Scaffold(
      appBar: AppBar(
        title: Text(supplier?.name ?? AppStrings.sessionActive),
        actions: [
          TextButton(
            onPressed: () => _showSwitchSupplierDialog(context, ref),
            child: const Text(AppStrings.switchSupplier,
                style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => _endSession(context, ref),
            child: Text(AppStrings.endSession,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: products.isEmpty
          ? EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: AppStrings.products,
              subtitle: AppStrings.emptyProducts,
            )
          : _SessionProductList(
              products: products,
              sessionState: sessionState,
            ),
    );
  }

  Future<void> _endSession(BuildContext context, WidgetRef ref) async {
    final session =
        await ref.read(sessionProvider.notifier).endSession();
    if (context.mounted && session != null) {
      context.push(AppRoutes.sessionSummary, extra: {
        'pricesRecorded': session.pricesRecorded,
        'supplierNames': session.supplierNames,
        'durationMinutes': session.duration.inMinutes,
      });
    }
  }

  void _showSwitchSupplierDialog(BuildContext context, WidgetRef ref) {
    final suppliers = ref.read(suppliersProvider).suppliers;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.switchSupplier),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suppliers.length,
            itemBuilder: (context, i) {
              final s = suppliers[i];
              return ListTile(
                title: Text(s.name),
                onTap: () {
                  ref
                      .read(sessionProvider.notifier)
                      .switchSupplier(s);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SessionProductList extends ConsumerWidget {
  final List<Product> products;
  final SessionState sessionState;

  const _SessionProductList({
    required this.products,
    required this.sessionState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SessionProgressBar(
          recorded: sessionState.pricesRecordedCount,
          total: products.length,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final product = products[i];
              final alreadySaved =
                  sessionState.savedProductIds.contains(product.id);
              return _SessionProductCard(
                product: product,
                supplier: sessionState.currentSupplier!,
                session: sessionState.activeSession!,
                alreadySaved: alreadySaved,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SessionProgressBar extends StatelessWidget {
  final int recorded;
  final int total;

  const _SessionProgressBar(
      {required this.recorded, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? recorded / total : 0.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$recorded / $total ${AppStrings.pricesRecorded}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.cardBorder,
            color: AppColors.emeraldGreen,
          ),
        ],
      ),
    );
  }
}

/// Per-product price entry card in session
class _SessionProductCard extends ConsumerStatefulWidget {
  final Product product;
  final Supplier supplier;
  final ShoppingSession session;
  final bool alreadySaved;

  const _SessionProductCard({
    required this.product,
    required this.supplier,
    required this.session,
    required this.alreadySaved,
  });

  @override
  ConsumerState<_SessionProductCard> createState() =>
      _SessionProductCardState();
}

class _SessionProductCardState
    extends ConsumerState<_SessionProductCard> {
  final _ctrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final priceStr = _ctrl.text.trim().replaceAll(' ', '');
    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorValidPrice)),
      );
      return;
    }
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final record = PriceRecord(
      productId: widget.product.id!,
      supplierId: widget.supplier.id!,
      sessionId: widget.session.id,
      price: price,
      unitTypeSnapshot: widget.product.unitType,
      packSizeSnapshot: widget.product.packSize,
      recordedAt: now,
      createdAt: now,
      supplierName: widget.supplier.name,
      supplierPhone: widget.supplier.phone,
      productName: widget.product.name,
    );

    await ref.read(sessionProvider.notifier).recordPrice(
          productId: widget.product.id!,
          price: price,
          record: record,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      _ctrl.clear();
      // Invalidate price cache for this product
      ref.invalidate(latestPricesProvider(widget.product.id!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(AppStrings.successPriceRecorded),
            duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final previousPriceAsync = ref.watch(
      latestPriceProvider((
        productId: widget.product.id!,
        supplierId: widget.supplier.id!,
      )),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: widget.alreadySaved ? AppColors.bestPriceBackground : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (widget.alreadySaved)
                  const Icon(Icons.check_circle,
                      color: AppColors.emeraldGreen, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            _PreviousPriceHint(priceAsync: previousPriceAsync),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d\s]')),
                    ],
                    decoration: InputDecoration(
                      hintText: AppStrings.enterPrice,
                      suffixText: AppStrings.dzd,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                LoadingOverlay(
                  isLoading: _isSaving,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(72, 44)),
                    child: const Text(AppStrings.savePrice),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousPriceHint extends StatelessWidget {
  final AsyncValue<PriceRecord?> priceAsync;

  const _PreviousPriceHint({required this.priceAsync});

  @override
  Widget build(BuildContext context) {
    return priceAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (record) {
        if (record == null) return const SizedBox.shrink();
        return Text(
          '${AppStrings.previousPrice}: ${DZDFormatter.format(record.price)}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted),
        );
      },
    );
  }
}
