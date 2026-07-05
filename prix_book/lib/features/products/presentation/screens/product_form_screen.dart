import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/unit_types.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../brands/presentation/providers/brands_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  final int? productId;

  const ProductFormScreen({super.key, this.product, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _packSizeCtrl;
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _notesCtrl;

  UnitType _unitType = UnitType.piece;
  int? _brandId;
  String? _imagePath;
  bool _isLoading = false;
  Product? _loadedProduct;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _packSizeCtrl = TextEditingController(
        text: p?.packSize != null ? '${p!.packSize}' : '');
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    _unitType = p?.unitType ?? UnitType.piece;
    _brandId = p?.brandId;
    _imagePath = p?.imagePath;
    if (widget.productId != null && p == null) _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await ref
          .read(getProductByIdUseCaseProvider)
          .call(widget.productId!);
      if (product != null && mounted) {
        setState(() {
          _loadedProduct = product;
          _nameCtrl.text = product.name;
          _packSizeCtrl.text =
              product.packSize != null ? '${product.packSize}' : '';
          _barcodeCtrl.text = product.barcode ?? '';
          _notesCtrl.text = product.notes ?? '';
          _unitType = product.unitType;
          _brandId = product.brandId;
          _imagePath = product.imagePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _packSizeCtrl.dispose();
    _barcodeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Product get _currentProduct => widget.product ?? _loadedProduct!;

  bool get _isEdit =>
      widget.product != null ||
      (widget.productId != null && _loadedProduct != null);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isLoading = true);
    final compressed = await ImageCompressor.compressAndSave(file.path);
    if (mounted) {
      setState(() {
        _imagePath = compressed;
        _isLoading = false;
      });
    }
  }

  void _removeImage() {
    if (_imagePath != null) {
      ImageCompressor.deleteImage(_imagePath!);
    }
    setState(() => _imagePath = null);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final packSize = _packSizeCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_packSizeCtrl.text.trim());
    final barcode = _barcodeCtrl.text.trim().isEmpty
        ? null
        : _barcodeCtrl.text.trim();

    final product = Product(
      id: _isEdit ? _currentProduct.id : null,
      name: _nameCtrl.text.trim(),
      brandId: _brandId,
      unitType: _unitType,
      packSize: packSize,
      barcode: barcode,
      imagePath: _imagePath,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _isEdit ? _currentProduct.createdAt : now,
      updatedAt: now,
    );

    try {
      if (_isEdit) {
        await ref.read(productsProvider.notifier).updateProduct(product);
      } else {
        await ref.read(productsProvider.notifier).createProduct(product);
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
    final brands = ref.watch(brandsProvider).brands;

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              _isEdit ? AppStrings.editProduct : AppStrings.addProduct),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Product name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.productName,
                  hintText: AppStrings.productNameHint,
                ),
                validator: Validators.productName,
                maxLength: 100,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Brand dropdown
              DropdownButtonFormField<int?>(
                value: _brandId,
                decoration: const InputDecoration(
                    labelText: AppStrings.brandOptional),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('—'),
                  ),
                  ...brands.map(
                    (b) => DropdownMenuItem<int?>(
                      value: b.id,
                      child: Text(b.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _brandId = v),
              ),
              const SizedBox(height: 16),

              // Unit type
              DropdownButtonFormField<UnitType>(
                value: _unitType,
                decoration:
                    const InputDecoration(labelText: AppStrings.unitType),
                items: UnitType.values
                    .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u.arabicLabel),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _unitType = v!),
              ),
              const SizedBox(height: 16),

              // Pack size
              TextFormField(
                controller: _packSizeCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.packSize,
                  hintText: AppStrings.packSizeHint,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.packSize,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Barcode
              TextFormField(
                controller: _barcodeCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.barcode,
                  hintText: AppStrings.barcodeHint,
                  suffixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.notes,
                  hintText: AppStrings.notesHint,
                ),
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Image picker
              _ImagePickerSection(
                imagePath: _imagePath,
                onPick: _pickImage,
                onRemove: _removeImage,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _save,
                child: Text(_isEdit ? AppStrings.save : AppStrings.addProduct),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerSection({
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.addImage,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: onPick,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.altRow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.primaryNavy, size: 32),
              ),
            ),
            if (imagePath != null) ...[
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.dangerRed),
                label: const Text(AppStrings.removeImage,
                    style: TextStyle(color: AppColors.dangerRed)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
