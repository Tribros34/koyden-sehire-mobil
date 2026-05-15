import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../data/farmer_product_repository.dart';
import '../models/farmer_product_model.dart';

class MyProductsState {
  final List<FarmerProductModel> items;
  final bool isLoading;
  final String? errorMessage;
  final String? statusFilter;

  const MyProductsState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter,
  });

  MyProductsState copyWith({
    List<FarmerProductModel>? items,
    bool? isLoading,
    String? errorMessage,
    String? statusFilter,
    bool clearError = false,
    bool clearStatus = false,
  }) =>
      MyProductsState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      );
}

final myProductsProvider =
    StateNotifierProvider<MyProductsController, MyProductsState>((ref) {
  return MyProductsController(ref.watch(farmerProductRepositoryProvider));
});

class MyProductsController extends StateNotifier<MyProductsState> {
  final FarmerProductRepository _repo;
  MyProductsController(this._repo) : super(const MyProductsState()) {
    refresh();
  }

  Future<void> setStatus(String? status) async {
    state = state.copyWith(
      statusFilter: status,
      clearStatus: status == null,
    );
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repo.list(status: state.statusFilter);
      state = state.copyWith(items: items, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  Future<bool> setStockStatus(String id, String stockStatus) async {
    try {
      await _repo.setStockStatus(id, stockStatus);
      await refresh();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}
