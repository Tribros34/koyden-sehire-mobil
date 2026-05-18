import 'package:get/get.dart';

import '../../../../app/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../data/product_repository.dart';
import '../models/product_model.dart';

class ProductListController extends GetxController {
  final ProductRepository _repo;
  ProductListController(this._repo);

  final RxList<ProductModel> items = <ProductModel>[].obs;
  final Rx<ProductFilter> filter = const ProductFilter().obs;
  final RxInt page = 1.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxInt total = 0.obs;
  final RxnString errorMessage = RxnString();

  Future<void> refresh() => _load(reset: true);

  Future<void> applyFilter(ProductFilter f) async {
    filter.value = f;
    await _load(reset: true);
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final nextPage = page.value + 1;
      final res = await _repo.list(
        filter: filter.value,
        page: nextPage,
        limit: AppConstants.productsPageSize,
      );
      items.addAll(res.items);
      page.value = res.pagination.page;
      hasMore.value = res.pagination.hasMore;
      total.value = res.pagination.total;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _load({required bool reset}) async {
    isLoading.value = true;
    errorMessage.value = null;
    if (reset) {
      items.clear();
      page.value = 1;
    }
    try {
      final res = await _repo.list(
        filter: filter.value,
        page: 1,
        limit: AppConstants.productsPageSize,
      );
      items.assignAll(res.items);
      page.value = res.pagination.page;
      hasMore.value = res.pagination.hasMore;
      total.value = res.pagination.total;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
