import 'package:get/get.dart';

import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/controllers/admin/admin_farmer_detail_controller.dart';

class AdminFarmerDetailBinding {
  static AdminFarmerDetailController create(String farmerId) {
    final repo = Get.find<AdminRepository>();
    return Get.put(AdminFarmerDetailController(repo, farmerId));
  }
}
