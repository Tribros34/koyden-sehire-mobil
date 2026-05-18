import 'package:get/get.dart';

import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/controllers/admin/admin_farmers_controller.dart';

class AdminFarmersBinding {
  static AdminFarmersController create() {
    final repo = Get.find<AdminRepository>();
    return Get.put(AdminFarmersController(repo));
  }
}
