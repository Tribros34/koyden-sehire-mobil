import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_application_detail_controller.dart';

class AdminApplicationDetailBinding extends Bindings {
  final AdminRepository repo;
  final String appId;
  AdminApplicationDetailBinding(this.repo, {required this.appId});

  @override
  void dependencies() {
    Get.put(AdminApplicationDetailController(repo, appId: appId));
  }
}
