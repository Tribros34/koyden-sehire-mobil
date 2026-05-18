import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../data/farmer_product_repository.dart';
import '../models/farmer_product_model.dart';

class MyProductsController extends GetxController {
  final FarmerProductRepository _repo;
  MyProductsController(this._repo);

  final RxList<FarmerProductModel> items = <FarmerProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString statusFilter = RxnString();

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  Future<void> setStatus(String? status) async {
    statusFilter.value = status;
    await refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _repo.list(status: statusFilter.value);
      items.assignAll(res);
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> setStockStatus(String id, String stockStatus) async {
    try {
      await _repo.setStockStatus(id, stockStatus);
      await refresh();
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    }
  }
}
