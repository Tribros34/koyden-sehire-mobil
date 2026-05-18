import 'package:get/get.dart';

import '../../../data/models/admin_invite_network_model.dart';
import '../../../data/repositories/admin_repository.dart';

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

  @override
  void onClose() {
    super.onClose();
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
