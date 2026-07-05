import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/unit_types.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/product.dart';

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int? filterBrandId;
  final UnitType? filterUnitType;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterBrandId,
    this.filterUnitType,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? filterBrandId,
    UnitType? filterUnitType,
    bool clearBrandFilter = false,
    bool clearUnitFilter = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterBrandId:
          clearBrandFilter ? null : (filterBrandId ?? this.filterBrandId),
      filterUnitType:
          clearUnitFilter ? null : (filterUnitType ?? this.filterUnitType),
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final Ref _ref;

  ProductsNotifier(this._ref) : super(const ProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final products = await _ref.read(getAllProductsUseCaseProvider).call(
            searchQuery:
                state.searchQuery.isEmpty ? null : state.searchQuery,
            brandId: state.filterBrandId,
            unitType: state.filterUnitType,
          );
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadProducts();
  }

  void setFilterBrand(int? brandId) {
    state = brandId == null
        ? state.copyWith(clearBrandFilter: true)
        : state.copyWith(filterBrandId: brandId);
    loadProducts();
  }

  void setFilterUnitType(UnitType? unitType) {
    state = unitType == null
        ? state.copyWith(clearUnitFilter: true)
        : state.copyWith(filterUnitType: unitType);
    loadProducts();
  }

  Future<void> createProduct(Product product) async {
    await _ref.read(createProductUseCaseProvider).call(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _ref.read(updateProductUseCaseProvider).call(product);
    await loadProducts();
  }

  Future<int> getPriceCount(int productId) async {
    return _ref
        .read(deleteProductUseCaseProvider)
        .getPriceCount(productId);
  }

  Future<void> deleteProduct(int productId) async {
    await _ref.read(deleteProductUseCaseProvider).call(productId);
    await loadProducts();
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier(ref);
});

// Single product detail provider
final productDetailProvider =
    FutureProvider.family<Product?, int>((ref, id) async {
  return ref.read(getProductByIdUseCaseProvider).call(id);
});
