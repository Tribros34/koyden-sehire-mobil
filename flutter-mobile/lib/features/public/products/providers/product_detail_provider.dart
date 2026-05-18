import 'package:get/get.dart';

import '../data/product_repository.dart';
import '../models/product_model.dart';

class ProductDetailController extends GetxController {
  final ProductRepository _repo;
  final String productId;
  ProductDetailController(this._repo, {required this.productId});

  final RxBool isLoading = false.obs;
  final Rxn<ProductModel> product = Rxn<ProductModel>();
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
      product.value = await _repo.getById(productId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
