import 'package:get/get.dart';

import 'package:koyden_sehire/core/errors/app_exception.dart';
import 'package:koyden_sehire/services/application_repository.dart';
import 'package:koyden_sehire/models/application_model.dart';

class InviteValidationController extends GetxController {
  final ApplicationRepository _repo;
  InviteValidationController(this._repo);

  final RxBool isLoading = false.obs;
  final Rxn<InviteInfo> info = Rxn<InviteInfo>();
  final RxnString errorMessage = RxnString();

  Future<bool> validate(String code) async {
    isLoading.value = true;
    errorMessage.value = null;
    info.value = null;
    try {
      final res = await _repo.validateInvite(code);
      info.value = res;
      isLoading.value = false;
      return true;
    } on AppException catch (e) {
      String msg;
      switch (e.code) {
        case 'INVALID_CODE_FORMAT':
        case 'INVALID_CODE':
        case 'CODE_EXPIRED':
          msg =
              'Davet kodu bulunamadı, süresi dolmuş veya kullanım hakkı tamamlanmış olabilir.';
          break;
        default:
          msg = e.message;
      }
      errorMessage.value = msg;
      isLoading.value = false;
      return false;
    }
  }

  void reset() {
    isLoading.value = false;
    info.value = null;
    errorMessage.value = null;
  }
}
