import 'package:get/get.dart';

import 'package:koyden_sehire/models/product_model.dart';
import 'package:koyden_sehire/services/farmer_repository.dart';
import 'package:koyden_sehire/models/farmer_model.dart';

class FarmerController extends GetxController {
  final FarmerRepository _repo;
  final String farmerId;
  FarmerController(this._repo, {required this.farmerId});

  final RxBool isLoadingProfile = false.obs;
  final Rxn<FarmerProfile> profile = Rxn<FarmerProfile>();
  final RxnString profileError = RxnString();

  final RxBool isLoadingProducts = false.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxnString productsError = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
    loadProducts();
  }

  Future<void> load() async {
    isLoadingProfile.value = true;
    profileError.value = null;
    try {
      profile.value = await _repo.getById(farmerId);
    } catch (e) {
      profileError.value = e.toString();
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> loadProducts() async {
    isLoadingProducts.value = true;
    productsError.value = null;
    try {
      products.assignAll(await _repo.getProducts(farmerId));
    } catch (e) {
      productsError.value = e.toString();
    } finally {
      isLoadingProducts.value = false;
    }
  }
}
