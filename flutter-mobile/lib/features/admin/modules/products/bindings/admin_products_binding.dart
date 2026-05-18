import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_products_controller.dart';

class AdminProductsBinding extends Bindings {
  final AdminRepository repo;
  AdminProductsBinding(this.repo);

  @override
  void dependencies() {
    Get.put(AdminProductsController(repo));
  }
}
