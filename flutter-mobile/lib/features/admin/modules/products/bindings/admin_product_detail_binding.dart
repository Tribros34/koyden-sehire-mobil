import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_product_detail_controller.dart';

class AdminProductDetailBinding extends Bindings {
  final AdminRepository repo;
  final String productId;
  AdminProductDetailBinding(this.repo, {required this.productId});

  @override
  void dependencies() {
    Get.put(AdminProductDetailController(repo, productId: productId));
  }
}
