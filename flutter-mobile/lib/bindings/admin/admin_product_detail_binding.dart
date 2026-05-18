import 'package:get/get.dart';

import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/controllers/admin/admin_product_detail_controller.dart';

class AdminProductDetailBinding extends Bindings {
  final AdminRepository repo;
  final String productId;
  AdminProductDetailBinding(this.repo, {required this.productId});

  @override
  void dependencies() {
    Get.put(AdminProductDetailController(repo, productId: productId));
  }
}
