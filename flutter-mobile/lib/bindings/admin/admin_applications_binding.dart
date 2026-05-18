import 'package:get/get.dart';

import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/controllers/admin/admin_applications_controller.dart';

class AdminApplicationsBinding extends Bindings {
  final AdminRepository repo;
  AdminApplicationsBinding(this.repo);

  @override
  void dependencies() {
    Get.put(AdminApplicationsController(repo));
  }
}
