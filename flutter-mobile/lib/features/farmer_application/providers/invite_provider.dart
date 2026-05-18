import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../data/application_repository.dart';
import '../models/application_model.dart';

class InviteValidationState {
  final bool isLoading;
  final InviteInfo? info;
  final String? errorMessage;

  const InviteValidationState({
    this.isLoading = false,
    this.info,
    this.errorMessage,
  });

  InviteValidationState copyWith({
    bool? isLoading,
    InviteInfo? info,
    String? errorMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) =>
      InviteValidationState(
        isLoading: isLoading ?? this.isLoading,
        info: clearInfo ? null : (info ?? this.info),
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

final inviteValidationProvider = StateNotifierProvider.autoDispose<
    InviteValidationController, InviteValidationState>((ref) {
  return InviteValidationController(ref.watch(applicationRepositoryProvider));
});

class InviteValidationController
    extends StateNotifier<InviteValidationState> {
  final ApplicationRepository _repo;
  InviteValidationController(this._repo) : super(const InviteValidationState());

  Future<bool> validate(String code) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearInfo: true,
    );
    try {
      final info = await _repo.validateInvite(code);
      state = state.copyWith(isLoading: false, info: info);
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
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }

  void reset() {
    state = const InviteValidationState();
  }
}
