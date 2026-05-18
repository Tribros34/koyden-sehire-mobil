import 'package:get/get.dart';

import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/controllers/admin/admin_categories_controller.dart';

class AdminCategoriesBinding extends Bindings {
  final AdminRepository repo;
  AdminCategoriesBinding(this.repo);

  @override
  void dependencies() {
    Get.put(AdminCategoriesController(repo));
  }
}
