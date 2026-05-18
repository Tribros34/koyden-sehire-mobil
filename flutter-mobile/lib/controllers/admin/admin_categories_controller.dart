import 'package:get/get.dart';

import 'package:koyden_sehire/models/admin/admin_category_model.dart';
import 'package:koyden_sehire/services/admin_repository.dart';

class AdminCategoriesController extends GetxController {
  final AdminRepository _repo;
  AdminCategoriesController(this._repo);

  final items = <AdminCategory>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }


  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      items.value = await _repo.getCategories();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
