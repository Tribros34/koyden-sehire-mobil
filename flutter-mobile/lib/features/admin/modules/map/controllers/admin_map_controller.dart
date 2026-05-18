import 'package:get/get.dart';

import '../../../data/models/admin_city_density_model.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminMapController extends GetxController {
  final AdminRepository _repo;
  AdminMapController(this._repo);

  final isLoading = true.obs;
  final error = ''.obs;
  final _items = <CityDensity>[].obs;
  final search = ''.obs;

  List<CityDensity> get filteredItems {
    final q = search.value.toLowerCase().trim();
    if (q.isEmpty) return _items;
    return _items
        .where((c) => c.city.toLowerCase().contains(q))
        .toList();
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
      _items.value = await _repo.getCityDensity();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
