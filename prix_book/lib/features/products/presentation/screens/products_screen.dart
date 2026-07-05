import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/confirm_delete_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppStrings.addProduct,
            onPressed: () => context.push(AppRoutes.addProduct),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchBar(
              hintText: AppStrings.searchProducts,
              onChanged: (q) =>
                  ref.read(productsProvider.notifier).setSearchQuery(q),
            ),
          ),
          Expanded(
            child: _buildContent(context, ref, state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addProduct),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addProduct),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ProductsState state) {
    if (state.isLoading) {
      return const Center(child: const CircularProgressIndicator());
    }
    if (state.products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: AppStrings.products,
        subtitle: state.searchQuery.isNotEmpty
            ? '${AppStrings.noResults} "${state.searchQuery}"'
            : AppStrings.emptyProducts,
        action: state.searchQuery.isEmpty
            ? ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addProduct),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addProduct),
              )
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        final product = state.products[index];
        return _ProductListTile(
          product: product,
          onDelete: () async {
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
              onConfirm: () => ref
                  .read(productsProvider.notifier)
                  .deleteProduct(product.id!),
            );
          },
        );
      },
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;

  const _ProductListTile({
    required this.product,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(product.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.push('/products/${product.id}/edit'),
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
          leading: _ProductAvatar(product: product),
          title: Text(
            product.name,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: _buildSubtitle(context),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
          ),
          onTap: () => context.push('/products/${product.id}'),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final parts = <String>[];
    if (product.brandName != null) parts.add(product.brandName!);
    parts.add(product.unitType.arabicLabel);
    if (product.packSize != null) {
      parts.add('${product.packSize} ${AppStrings.unitPiece}');
    }
    return Text(
      parts.join(' • '),
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: AppColors.textMuted),
    );
  }
}

class _ProductAvatar extends StatelessWidget {
  final Product product;

  const _ProductAvatar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.altRow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryNavy),
    );
  }
}
