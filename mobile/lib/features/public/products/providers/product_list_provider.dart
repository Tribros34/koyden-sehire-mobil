import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../data/product_repository.dart';
import '../models/product_model.dart';

class ProductListState {
  final List<ProductModel> items;
  final ProductFilter filter;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int total;
  final String? errorMessage;

  const ProductListState({
    this.items = const [],
    this.filter = const ProductFilter(),
    this.page = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.total = 0,
    this.errorMessage,
  });

  ProductListState copyWith({
    List<ProductModel>? items,
    ProductFilter? filter,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? total,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ProductListState(
        items: items ?? this.items,
        filter: filter ?? this.filter,
        page: page ?? this.page,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        total: total ?? this.total,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

final productListProvider =
    StateNotifierProvider<ProductListController, ProductListState>((ref) {
  return ProductListController(ref.watch(productRepositoryProvider));
});

class ProductListController extends StateNotifier<ProductListState> {
  final ProductRepository _repo;

  ProductListController(this._repo) : super(const ProductListState());

  Future<void> refresh() => _load(reset: true);

  Future<void> applyFilter(ProductFilter filter) async {
    state = state.copyWith(filter: filter);
    await _load(reset: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final res = await _repo.list(
        filter: state.filter,
        page: nextPage,
        limit: AppConstants.productsPageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...res.items],
        page: res.pagination.page,
        hasMore: res.pagination.hasMore,
        total: res.pagination.total,
        isLoadingMore: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.message);
    }
  }

  Future<void> _load({required bool reset}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      items: reset ? const [] : state.items,
      page: reset ? 1 : state.page,
    );
    try {
      final res = await _repo.list(
        filter: state.filter,
        page: 1,
        limit: AppConstants.productsPageSize,
      );
      state = state.copyWith(
        items: res.items,
        page: res.pagination.page,
        hasMore: res.pagination.hasMore,
        total: res.pagination.total,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }
}
