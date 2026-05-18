import 'package:get/get.dart';

import '../../../data/models/admin_product_model.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminProductDetailController extends GetxController {
  final AdminRepository _repo;
  final String productId;
  AdminProductDetailController(this._repo, {required this.productId});

  final product = Rx<AdminProduct?>(null);
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      product.value = await _repo.getProduct(productId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> moderate(String action, {String? reason}) async {
    isSubmitting.value = true;
    try {
      await _repo.moderateProduct(productId, action, reason: reason);
      await load();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
