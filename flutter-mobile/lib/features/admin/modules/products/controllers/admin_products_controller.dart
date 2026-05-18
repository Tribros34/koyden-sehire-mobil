import 'package:get/get.dart';

import '../../../data/models/admin_product_model.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminProductsController extends GetxController {
  final AdminRepository _repo;
  AdminProductsController(this._repo);

  final items = <AdminProduct>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;
  final search = ''.obs;

  List<AdminProduct> get filteredItems {
    final q = search.value.toLowerCase();
    if (q.isEmpty) return items;
    return items.where((p) {
      return p.title.toLowerCase().contains(q) ||
          (p.farmer?.displayName ?? '').toLowerCase().contains(q) ||
          (p.category?.name ?? '').toLowerCase().contains(q);
    }).toList();
  }

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
      items.value = await _repo.getProducts();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
