import 'package:get/get.dart';

import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/controllers/admin/admin_products_controller.dart';

class AdminProductsBinding extends Bindings {
  final AdminRepository repo;
  AdminProductsBinding(this.repo);

  @override
  void dependencies() {
    Get.put(AdminProductsController(repo));
  }
}
