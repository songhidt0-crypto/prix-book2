import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/confirm_delete_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/brand.dart';
import '../providers/brands_provider.dart';

class BrandsScreen extends ConsumerWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(brandsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageBrands),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showBrandDialog(context, ref, null),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: const CircularProgressIndicator())
          : state.brands.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.label_outline,
                  title: AppStrings.noBrands,
                  subtitle: AppStrings.noBrandsSubtitle,
                  action: ElevatedButton.icon(
                    onPressed: () => _showBrandDialog(context, ref, null),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addBrand),
                  ),
                )
              : ListView.builder(
                  itemCount: state.brands.length,
                  itemBuilder: (context, i) {
                    final brand = state.brands[i];
                    return _BrandTile(
                      brand: brand,
                      onEdit: () =>
                          _showBrandDialog(context, ref, brand),
                      onDelete: () async {
                        final count = await ref
                            .read(brandsProvider.notifier)
                            .getProductCount(brand.id!);
                        if (!context.mounted) return;
                        ConfirmDeleteDialog.show(
                          context,
                          title: AppStrings.deleteBrand,
                          message: count > 0
                              ? '${AppStrings.thisWillDelete} $count ${AppStrings.products}.\n${AppStrings.deleteBrandConfirm}'
                              : AppStrings.deleteBrandConfirm,
                          onConfirm: () => ref
                              .read(brandsProvider.notifier)
                              .deleteBrand(brand.id!),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBrandDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBrandDialog(BuildContext context, WidgetRef ref, Brand? existing) {
    showDialog(
      context: context,
      builder: (_) => _BrandDialog(brand: existing),
    );
  }
}

class _BrandTile extends StatelessWidget {
  final Brand brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BrandTile({
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(brand.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
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
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.altRow,
          child: Icon(Icons.label_outline, color: AppColors.primaryNavy),
        ),
        title: Text(brand.name,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: brand.notes != null
            ? Text(brand.notes!,
                style: const TextStyle(color: AppColors.textMuted))
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onEdit,
      ),
    );
  }
}

class _BrandDialog extends ConsumerStatefulWidget {
  final Brand? brand;

  const _BrandDialog({this.brand});

  @override
  ConsumerState<_BrandDialog> createState() => _BrandDialogState();
}

class _BrandDialogState extends ConsumerState<_BrandDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  bool _isLoading = false;

  bool get _isEdit => widget.brand != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.brand?.name ?? '');
    _notesCtrl = TextEditingController(text: widget.brand?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final brand = Brand(
      id: widget.brand?.id,
      name: _nameCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.brand?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_isEdit) {
        await ref.read(brandsProvider.notifier).updateBrand(brand);
      } else {
        await ref.read(brandsProvider.notifier).createBrand(brand);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(_isEdit ? AppStrings.editBrand : AppStrings.addBrand),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.brandName,
                hintText: AppStrings.brandNameHint,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? AppStrings.errorRequired
                  : null,
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.notes,
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEdit ? AppStrings.save : AppStrings.addBrand),
        ),
      ],
    );
  }
}
