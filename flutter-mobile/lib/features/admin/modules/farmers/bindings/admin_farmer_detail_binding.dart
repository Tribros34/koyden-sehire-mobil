import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_farmer_detail_controller.dart';

class AdminFarmerDetailBinding {
  static AdminFarmerDetailController create(String farmerId) {
    final repo = Get.find<AdminRepository>();
    return Get.put(AdminFarmerDetailController(repo, farmerId));
  }
}
