import 'dart:async';

import 'package:get/get.dart';

import 'package:koyden_sehire/app/constants.dart';
import 'package:koyden_sehire/core/errors/app_exception.dart';
import 'package:koyden_sehire/services/otp_repository.dart';

class OtpController extends GetxController {
  final OtpRepository _repo;
  OtpController(this._repo);

  final RxBool isSending = false.obs;
  final RxBool isVerifying = false.obs;
  final RxnString errorMessage = RxnString();
  final RxInt cooldownSeconds = 0.obs;
  final RxBool verified = false.obs;

  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startCooldown() {
    _timer?.cancel();
    cooldownSeconds.value = AppConstants.otpResendCooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = cooldownSeconds.value - 1;
      if (next <= 0) {
        t.cancel();
        cooldownSeconds.value = 0;
      } else {
        cooldownSeconds.value = next;
      }
    });
  }

  Future<bool> send(String phone) async {
    if (cooldownSeconds.value > 0) return false;
    isSending.value = true;
    errorMessage.value = null;
    try {
      await _repo.send(phone);
      _startCooldown();
      isSending.value = false;
      return true;
    } on AppException catch (e) {
      String msg = e.message;
      if (e.code == 'COOLDOWN_ACTIVE') {
        msg = 'Az önce gönderildi, biraz bekleyin.';
        _startCooldown();
      } else if (e.code == 'INVALID_PHONE') {
        msg = 'Geçersiz telefon numarası';
      }
      errorMessage.value = msg;
      isSending.value = false;
      return false;
    } catch (_) {
      errorMessage.value = 'Kod gönderilemedi';
      isSending.value = false;
      return false;
    }
  }

  Future<bool> verify({required String phone, required String code}) async {
    isVerifying.value = true;
    errorMessage.value = null;
    try {
      await _repo.verify(phone: phone, code: code);
      isVerifying.value = false;
      verified.value = true;
      return true;
    } on AppException catch (e) {
      String msg = e.message;
      if (e.code == 'INVALID_CODE') {
        msg = 'Kod hatalı, tekrar deneyin';
      } else if (e.code == 'OTP_EXPIRED') {
        msg = 'Kodun süresi doldu, tekrar gönderin';
      } else if (e.code == 'MAX_ATTEMPTS') {
        msg = 'Çok fazla yanlış deneme. Yeni kod isteyin.';
      }
      errorMessage.value = msg;
      isVerifying.value = false;
      return false;
    } catch (_) {
      errorMessage.value = 'Doğrulama başarısız';
      isVerifying.value = false;
      return false;
    }
  }
}
