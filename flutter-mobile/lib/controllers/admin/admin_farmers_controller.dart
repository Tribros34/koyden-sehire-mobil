import 'package:get/get.dart';

import 'package:koyden_sehire/models/admin/admin_farmer_model.dart';
import 'package:koyden_sehire/services/admin_repository.dart';

class AdminFarmersController extends GetxController {
  final AdminRepository _repo;
  AdminFarmersController(this._repo);

  final isLoading = true.obs;
  final error = ''.obs;
  final _items = <AdminFarmer>[].obs;
  final search = ''.obs;

  List<AdminFarmer> get filteredItems {
    final q = search.value.toLowerCase().trim();
    if (q.isEmpty) return _items;
    return _items.where((f) {
      return f.fullName.toLowerCase().contains(q) ||
          f.city.toLowerCase().contains(q) ||
          (f.inviteCode?.toLowerCase().contains(q) ?? false);
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
      _items.value = await _repo.getFarmers();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
