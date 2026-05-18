import 'package:get/get.dart';

import 'package:koyden_sehire/models/admin/admin_farmer_model.dart';
import 'package:koyden_sehire/services/admin_repository.dart';

class AdminFarmerDetailController extends GetxController {
  final AdminRepository _repo;
  final String farmerId;

  AdminFarmerDetailController(this._repo, this.farmerId);

  final isLoading = true.obs;
  final isActioning = false.obs;
  final error = ''.obs;
  final Rx<AdminFarmerDetail?> farmer = Rx(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }


  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      farmer.value = await _repo.getFarmer(farmerId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus() async {
    final f = farmer.value;
    if (f == null) return;
    isActioning.value = true;
    try {
      final action = f.isActive ? 'suspend' : 'activate';
      await _repo.toggleFarmerStatus(farmerId, action);
      await load();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isActioning.value = false;
    }
  }

  Future<void> updateQuota(int quota) async {
    isActioning.value = true;
    try {
      await _repo.updateFarmerQuota(farmerId, quota);
      await load();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isActioning.value = false;
    }
  }
}
