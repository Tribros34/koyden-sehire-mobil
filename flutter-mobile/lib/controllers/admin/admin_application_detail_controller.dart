import 'package:get/get.dart';

import 'package:koyden_sehire/models/admin/admin_application_model.dart';
import 'package:koyden_sehire/services/admin_repository.dart';

class AdminApplicationDetailController extends GetxController {
  final AdminRepository _repo;
  final String appId;
  AdminApplicationDetailController(this._repo, {required this.appId});

  final application = Rx<AdminApplication?>(null);
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }


  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      application.value = await _repo.getApplication(appId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> review(String action, {String? reason}) async {
    isSubmitting.value = true;
    try {
      await _repo.reviewApplication(appId, action, reason: reason);
      await load();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
