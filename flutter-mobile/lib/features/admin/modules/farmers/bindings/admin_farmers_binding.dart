import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_farmers_controller.dart';

class AdminFarmersBinding {
  static AdminFarmersController create() {
    final repo = Get.find<AdminRepository>();
    return Get.put(AdminFarmersController(repo));
  }
}
