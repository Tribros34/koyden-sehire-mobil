import 'package:get/get.dart';

import 'package:koyden_sehire/models/admin/admin_invite_network_model.dart';
import 'package:koyden_sehire/services/admin_repository.dart';

class AdminInviteNetworkController extends GetxController {
  final AdminRepository _repo;
  AdminInviteNetworkController(this._repo);

  final isLoading = true.obs;
  final error = ''.obs;
  final Rx<InviteNode?> root = Rx(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }


  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      root.value = await _repo.getInviteNetwork();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
