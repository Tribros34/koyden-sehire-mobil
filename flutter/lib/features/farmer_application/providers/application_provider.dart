import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../data/application_repository.dart';
import '../models/application_model.dart';

class ApplicationFormState {
  final InviteInfo? invite;
  final ApplicationFormData data;
  final int currentStep; // 0..4
  final bool phoneVerified;
  final bool isUploading;
  final double uploadProgress;
  final bool isSubmitting;
  final String? errorMessage;
  final bool submitted;

  const ApplicationFormState({
    this.invite,
    this.data = const ApplicationFormData(),
    this.currentStep = 0,
    this.phoneVerified = false,
    this.isUploading = false,
    this.uploadProgress = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.submitted = false,
  });

  ApplicationFormState copyWith({
    InviteInfo? invite,
    ApplicationFormData? data,
    int? currentStep,
    bool? phoneVerified,
    bool? isUploading,
    double? uploadProgress,
    bool? isSubmitting,
    String? errorMessage,
    bool? submitted,
    bool clearError = false,
  }) =>
      ApplicationFormState(
        invite: invite ?? this.invite,
        data: data ?? this.data,
        currentStep: currentStep ?? this.currentStep,
        phoneVerified: phoneVerified ?? this.phoneVerified,
        isUploading: isUploading ?? this.isUploading,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        submitted: submitted ?? this.submitted,
      );
}

final applicationFormProvider = StateNotifierProvider<ApplicationFormController,
    ApplicationFormState>((ref) {
  return ApplicationFormController(ref.watch(applicationRepositoryProvider));
});

class ApplicationFormController extends StateNotifier<ApplicationFormState> {
  final ApplicationRepository _repo;
  ApplicationFormController(this._repo) : super(const ApplicationFormState());

  void setInvite(InviteInfo info) {
    state = state.copyWith(invite: info);
  }

  void updateData(ApplicationFormData Function(ApplicationFormData d) update) {
    state = state.copyWith(data: update(state.data));
  }

  void setPhoneVerified(bool verified) {
    state = state.copyWith(phoneVerified: verified);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void next() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previous() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void reset() {
    state = const ApplicationFormState();
  }

  Future<bool> uploadVideo(File file, {String contentType = 'video/mp4'}) async {
    final invite = state.invite;
    if (invite == null) return false;
    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0,
      clearError: true,
    );
    try {
      final presigned = await _repo.getVideoPresignedUrl(
        phone: state.data.phone,
        inviteCode: invite.code,
        contentType: contentType,
      );
      if (presigned.uploadUrl.isEmpty) {
        // No-op storage provider in dev — accept gracefully and skip upload.
        state = state.copyWith(
          isUploading: false,
          errorMessage:
              'Sunucuda video depolama yapılandırılmamış. Şimdilik geçebilirsiniz.',
        );
        return false;
      }
      await _repo.uploadVideoToPresigned(
        uploadUrl: presigned.uploadUrl,
        file: file,
        contentType: contentType,
        onProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(uploadProgress: sent / total);
          }
        },
      );
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 1,
        data: state.data.copyWith(applicationVideoKey: presigned.key),
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isUploading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Video yüklenemedi',
      );
      return false;
    }
  }

  Future<bool> submit() async {
    final invite = state.invite;
    if (invite == null) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.submit(inviteCode: invite.code, data: state.data);
      state = state.copyWith(isSubmitting: false, submitted: true);
      return true;
    } on AppException catch (e) {
      String msg = e.message;
      if (e.code == 'CONFLICT') {
        msg =
            'Bu telefon numarasıyla aktif bir başvuru bulunuyor veya kayıtlı bir hesap mevcut.';
      }
      state = state.copyWith(isSubmitting: false, errorMessage: msg);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Başvuru gönderilemedi',
      );
      return false;
    }
  }
}
