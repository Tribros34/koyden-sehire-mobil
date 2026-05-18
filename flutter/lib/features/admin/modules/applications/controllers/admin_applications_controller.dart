import 'package:get/get.dart';

import '../../../data/models/admin_application_model.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminApplicationsController extends GetxController {
  final AdminRepository _repo;
  AdminApplicationsController(this._repo);

  final items = <AdminApplication>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;
  final search = ''.obs;

  List<AdminApplication> get filteredItems {
    final q = search.value.toLowerCase();
    if (q.isEmpty) return items;
    return items.where((a) {
      return a.fullName.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q) ||
          (a.inviteCode ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      items.value = await _repo.getApplications();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
