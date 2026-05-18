import 'package:get/get.dart';

import 'package:koyden_sehire/services/category_repository.dart';
import 'package:koyden_sehire/models/category_model.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repo;
  CategoryController(this._repo);

  final RxBool isLoading = false.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxnString error = RxnString();

  /// Flat list of every category (root + children).
  List<CategoryModel> get flat {
    final out = <CategoryModel>[];
    void walk(List<CategoryModel> nodes) {
      for (final n in nodes) {
        out.add(n);
        if (n.children.isNotEmpty) walk(n.children);
      }
    }
    walk(categories);
    return out;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final res = await _repo.getTree();
      categories.assignAll(res);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

CategoryModel? findCategoryById(List<CategoryModel> flat, String id) {
  for (final c in flat) {
    if (c.id == id) return c;
  }
  return null;
}
