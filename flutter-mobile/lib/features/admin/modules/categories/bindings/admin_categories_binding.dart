import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_categories_controller.dart';

class AdminCategoriesBinding extends Bindings {
  final AdminRepository repo;
  AdminCategoriesBinding(this.repo);

  @override
  void dependencies() {
    Get.put(AdminCategoriesController(repo));
  }
}
