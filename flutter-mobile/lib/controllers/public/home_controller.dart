import 'package:get/get.dart';

import 'package:koyden_sehire/models/farmer_model.dart';
import 'package:koyden_sehire/services/product_repository.dart';
import 'package:koyden_sehire/models/product_model.dart';

class HomeController extends GetxController {
  final ProductRepository _repo;
  HomeController(this._repo);

  final RxBool isLoading = false.obs;
  final RxList<ProductModel> newProducts = <ProductModel>[].obs;
  final RxList<FarmerSummary> featuredFarmers = <FarmerSummary>[].obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final res = await _repo.list(
        filter: const ProductFilter(),
        page: 1,
        limit: 10,
      );
      newProducts.assignAll(res.items);

      // Derive featured farmers from latest products (no /farmers list endpoint).
      final seen = <String>{};
      final farmers = <FarmerSummary>[];
      for (final p in res.items) {
        final f = p.farmer;
        if (f == null) continue;
        if (seen.add(f.id)) farmers.add(f);
        if (farmers.length >= 8) break;
      }
      featuredFarmers.assignAll(farmers);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
