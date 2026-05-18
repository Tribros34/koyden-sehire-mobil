import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants.dart';
import '../../../core/errors/app_exception.dart';
import '../data/otp_repository.dart';

class OtpState {
  final bool isSending;
  final bool isVerifying;
  final String? errorMessage;
  final int cooldownSeconds;
  final bool verified;

  const OtpState({
    this.isSending = false,
    this.isVerifying = false,
    this.errorMessage,
    this.cooldownSeconds = 0,
    this.verified = false,
  });

  OtpState copyWith({
    bool? isSending,
    bool? isVerifying,
    String? errorMessage,
    int? cooldownSeconds,
    bool? verified,
    bool clearError = false,
  }) =>
      OtpState(
        isSending: isSending ?? this.isSending,
        isVerifying: isVerifying ?? this.isVerifying,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
        verified: verified ?? this.verified,
      );
}

final otpControllerProvider =
    StateNotifierProvider.autoDispose<OtpController, OtpState>((ref) {
  return OtpController(ref.watch(otpRepositoryProvider));
});

class OtpController extends StateNotifier<OtpState> {
  final OtpRepository _repo;
  Timer? _timer;

  OtpController(this._repo) : super(const OtpState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    state = state.copyWith(cooldownSeconds: AppConstants.otpResendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = state.cooldownSeconds - 1;
      if (next <= 0) {
        t.cancel();
        state = state.copyWith(cooldownSeconds: 0);
      } else {
        state = state.copyWith(cooldownSeconds: next);
      }
    });
  }

  Future<bool> send(String phone) async {
    if (state.cooldownSeconds > 0) return false;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      await _repo.send(phone);
      _startCooldown();
      state = state.copyWith(isSending: false);
      return true;
    } on AppException catch (e) {
      String msg = e.message;
      if (e.code == 'COOLDOWN_ACTIVE') {
        msg = 'Az önce gönderildi, biraz bekleyin.';
        _startCooldown();
      } else if (e.code == 'INVALID_PHONE') {
        msg = 'Geçersiz telefon numarası';
      }
      state = state.copyWith(isSending: false, errorMessage: msg);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Kod gönderilemedi',
      );
      return false;
    }
  }

  Future<bool> verify({required String phone, required String code}) async {
    state = state.copyWith(isVerifying: true, clearError: true);
    try {
      await _repo.verify(phone: phone, code: code);
      state = state.copyWith(isVerifying: false, verified: true);
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
      state = state.copyWith(isVerifying: false, errorMessage: msg);
      return false;
    } catch (_) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: 'Doğrulama başarısız',
      );
      return false;
    }
  }
}
