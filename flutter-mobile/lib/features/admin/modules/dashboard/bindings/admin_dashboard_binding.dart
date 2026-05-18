import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  final AdminRepository repo;
  AdminDashboardBinding(this.repo);

  @override
  void dependencies() {
    Get.put(AdminDashboardController(repo));
  }
}
