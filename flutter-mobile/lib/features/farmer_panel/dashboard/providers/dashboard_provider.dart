import 'package:get/get.dart';

import '../data/dashboard_repository.dart';
import '../models/dashboard_model.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repo;
  DashboardController(this._repo);

  final RxBool isLoading = false.obs;
  final Rxn<DashboardData> data = Rxn<DashboardData>();
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      data.value = await _repo.load();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
