import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/brand.dart';

class BrandsState {
  final List<Brand> brands;
  final bool isLoading;
  final String? error;

  const BrandsState({
    this.brands = const [],
    this.isLoading = false,
    this.error,
  });

  BrandsState copyWith({
    List<Brand>? brands,
    bool? isLoading,
    String? error,
  }) {
    return BrandsState(
      brands: brands ?? this.brands,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BrandsNotifier extends StateNotifier<BrandsState> {
  final Ref _ref;

  BrandsNotifier(this._ref) : super(const BrandsState()) {
    loadBrands();
  }

  Future<void> loadBrands() async {
    state = state.copyWith(isLoading: true);
    try {
      final brands =
          await _ref.read(getAllBrandsUseCaseProvider).call();
      state = BrandsState(brands: brands);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createBrand(Brand brand) async {
    try {
      await _ref.read(createBrandUseCaseProvider).call(brand);
      await loadBrands();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBrand(Brand brand) async {
    try {
      await _ref.read(updateBrandUseCaseProvider).call(brand);
      await loadBrands();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getProductCount(int brandId) async {
    return _ref
        .read(deleteBrandUseCaseProvider)
        .getProductCount(brandId);
  }

  Future<void> deleteBrand(int brandId) async {
    try {
      await _ref.read(deleteBrandUseCaseProvider).call(brandId);
      await loadBrands();
    } catch (e) {
      rethrow;
    }
  }
}

final brandsProvider =
    StateNotifierProvider<BrandsNotifier, BrandsState>((ref) {
  return BrandsNotifier(ref);
});
