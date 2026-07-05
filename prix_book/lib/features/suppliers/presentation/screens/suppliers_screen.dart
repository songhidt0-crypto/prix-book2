import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/confirm_delete_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/supplier.dart';
import '../providers/suppliers_provider.dart';

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.suppliers),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppStrings.addSupplier,
            onPressed: () => context.push(AppRoutes.addSupplier),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchBar(
              hintText: AppStrings.searchSuppliers,
              onChanged: (q) =>
                  ref.read(suppliersProvider.notifier).setSearchQuery(q),
            ),
          ),
          Expanded(child: _buildContent(context, ref, state)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addSupplier),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addSupplier),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, SuppliersState state) {
    if (state.isLoading) {
      return const Center(child: const CircularProgressIndicator());
    }
    if (state.suppliers.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.store_outlined,
        title: AppStrings.suppliers,
        subtitle: state.searchQuery.isNotEmpty
            ? '${AppStrings.noResults} "${state.searchQuery}"'
            : AppStrings.emptySuppliers,
        action: state.searchQuery.isEmpty
            ? ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addSupplier),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addSupplier),
              )
            : null,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: state.suppliers.length,
      itemBuilder: (context, i) {
        final supplier = state.suppliers[i];
        return _SupplierListTile(
          supplier: supplier,
          onMarkVisited: () => ref
              .read(suppliersProvider.notifier)
              .markVisitedToday(supplier.id!),
          onDelete: () async {
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
              onConfirm: () => ref
                  .read(suppliersProvider.notifier)
                  .deleteSupplier(supplier.id!),
            );
          },
        );
      },
    );
  }
}

class _SupplierListTile extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onMarkVisited;
  final VoidCallback onDelete;

  const _SupplierListTile({
    required this.supplier,
    required this.onMarkVisited,
    required this.onDelete,
  });

  Future<void> _callPhone(BuildContext context) async {
    if (!supplier.hasPhone) return;
    final uri = Uri.parse('tel:${supplier.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(supplier.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.push('/suppliers/${supplier.id}/edit'),
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: AppStrings.edit,
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.dangerRed,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: AppStrings.delete,
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.altRow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.store_outlined,
                color: AppColors.primaryNavy),
          ),
          title: Text(
            supplier.name,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (supplier.lastVisitDate != null)
                Text(
                  '${AppStrings.lastVisit}: ${DateFormatter.formatDate(supplier.lastVisitDate!)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                )
              else
                Text(
                  AppStrings.neverVisited,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              if (supplier.priceCount > 0)
                Text(
                  '${supplier.priceCount} ${AppStrings.productCount}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.emeraldGreen),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (supplier.hasPhone)
                IconButton(
                  icon: const Icon(Icons.phone_outlined,
                      color: AppColors.primaryNavy),
                  onPressed: () => _callPhone(context),
                  tooltip: supplier.phone,
                ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
          onTap: () => context.push('/suppliers/${supplier.id}'),
        ),
      ),
    );
  }
}
