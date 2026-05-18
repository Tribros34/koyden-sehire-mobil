import 'package:get/get.dart';

import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/controllers/admin/admin_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  final AdminRepository repo;
  AdminDashboardBinding(this.repo);

  @override
  void dependencies() {
    Get.put(AdminDashboardController(repo));
  }
}
