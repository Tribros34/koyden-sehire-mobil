import 'package:get/get.dart';

import '../../../data/models/admin_dashboard_model.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminDashboardController extends GetxController {
  final AdminRepository _repo;
  AdminDashboardController(this._repo);

  final data = Rx<AdminDashboardData?>(null);
  final isLoading = true.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    // No Workers/StreamSubscriptions to cancel today, but keep the override
    // wired so future additions don't leak.
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      data.value = await _repo.getDashboard();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
