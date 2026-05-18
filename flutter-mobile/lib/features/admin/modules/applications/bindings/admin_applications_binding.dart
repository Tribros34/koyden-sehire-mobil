import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_applications_controller.dart';

class AdminApplicationsBinding extends Bindings {
  final AdminRepository repo;
  AdminApplicationsBinding(this.repo);

  @override
  void dependencies() {
    Get.put(AdminApplicationsController(repo));
  }
}
