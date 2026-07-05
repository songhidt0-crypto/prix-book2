import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/supplier.dart';

class SuppliersState {
  final List<Supplier> suppliers;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const SuppliersState({
    this.suppliers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  SuppliersState copyWith({
    List<Supplier>? suppliers,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return SuppliersState(
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SuppliersNotifier extends StateNotifier<SuppliersState> {
  final Ref _ref;

  SuppliersNotifier(this._ref) : super(const SuppliersState()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    state = state.copyWith(isLoading: true);
    try {
      final suppliers = await _ref.read(getAllSuppliersUseCaseProvider).call(
            searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
          );
      state = state.copyWith(suppliers: suppliers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadSuppliers();
  }

  Future<void> createSupplier(Supplier supplier) async {
    await _ref.read(createSupplierUseCaseProvider).call(supplier);
    await loadSuppliers();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _ref.read(updateSupplierUseCaseProvider).call(supplier);
    await loadSuppliers();
  }

  Future<int> getPriceCount(int supplierId) async {
    return _ref
        .read(deleteSupplierUseCaseProvider)
        .getPriceCount(supplierId);
  }

  Future<void> deleteSupplier(int supplierId) async {
    await _ref.read(deleteSupplierUseCaseProvider).call(supplierId);
    await loadSuppliers();
  }

  Future<void> markVisitedToday(int supplierId) async {
    await _ref.read(markSupplierVisitedUseCaseProvider).call(supplierId);
    await loadSuppliers();
  }
}

final suppliersProvider =
    StateNotifierProvider<SuppliersNotifier, SuppliersState>((ref) {
  return SuppliersNotifier(ref);
});

final supplierDetailProvider =
    FutureProvider.family<Supplier?, int>((ref, id) async {
  return ref.read(getSupplierByIdUseCaseProvider).call(id);
});
