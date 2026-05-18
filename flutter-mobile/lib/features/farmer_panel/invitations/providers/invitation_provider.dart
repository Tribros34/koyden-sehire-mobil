import 'package:get/get.dart';

import '../data/invitation_repository.dart';
import '../models/invitation_model.dart';

class InvitationController extends GetxController {
  final InvitationRepository _repo;
  InvitationController(this._repo);

  final RxBool isLoading = false.obs;
  final RxList<InviteCodeItem> items = <InviteCodeItem>[].obs;
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
      items.assignAll(await _repo.list());
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
