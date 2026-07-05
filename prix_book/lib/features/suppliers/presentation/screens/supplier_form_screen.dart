import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/supplier.dart';
import '../providers/suppliers_provider.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final Supplier? supplier;
  final int? supplierId;

  const SupplierFormScreen({super.key, this.supplier, this.supplierId});

  @override
  ConsumerState<SupplierFormScreen> createState() =>
      _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  bool _isLoading = false;
  Supplier? _loadedSupplier;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _addressCtrl = TextEditingController(text: s?.address ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    if (widget.supplierId != null && s == null) _loadSupplier();
  }

  Future<void> _loadSupplier() async {
    setState(() => _isLoading = true);
    final supplier = await ref
        .read(getSupplierByIdUseCaseProvider)
        .call(widget.supplierId!);
    if (supplier != null && mounted) {
      setState(() {
        _loadedSupplier = supplier;
        _nameCtrl.text = supplier.name;
        _phoneCtrl.text = supplier.phone ?? '';
        _addressCtrl.text = supplier.address ?? '';
        _notesCtrl.text = supplier.notes ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isEdit =>
      widget.supplier != null ||
      (widget.supplierId != null && _loadedSupplier != null);

  Supplier? get _current => widget.supplier ?? _loadedSupplier;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final supplier = Supplier(
      id: _isEdit ? _current!.id : null,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      notes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      lastVisitDate: _isEdit ? _current!.lastVisitDate : null,
      createdAt: _isEdit ? _current!.createdAt : now,
      updatedAt: now,
    );

    try {
      if (_isEdit) {
        await ref.read(suppliersProvider.notifier).updateSupplier(supplier);
      } else {
        await ref.read(suppliersProvider.notifier).createSupplier(supplier);
      }
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.successSaved)),
        );
      }
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
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              _isEdit ? AppStrings.editSupplier : AppStrings.addSupplier),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.supplierName,
                  hintText: AppStrings.supplierNameHint,
                ),
                validator: Validators.supplierName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.phone,
                  hintText: AppStrings.phoneHint,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.address,
                  hintText: AppStrings.addressHint,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.notes,
                  hintText: AppStrings.notesHint,
                ),
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: Text(
                    _isEdit ? AppStrings.save : AppStrings.addSupplier),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
