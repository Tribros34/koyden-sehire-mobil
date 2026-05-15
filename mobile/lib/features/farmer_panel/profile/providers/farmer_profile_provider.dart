import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../products/data/farmer_product_repository.dart';
import '../data/farmer_profile_repository.dart';
import '../models/farmer_profile_edit_model.dart';

class FarmerProfileState {
  final FarmerProfileEdit? profile;
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingImage;
  final String? errorMessage;
  final bool saved;

  const FarmerProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.errorMessage,
    this.saved = false,
  });

  FarmerProfileState copyWith({
    FarmerProfileEdit? profile,
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingImage,
    String? errorMessage,
    bool? saved,
    bool clearError = false,
  }) =>
      FarmerProfileState(
        profile: profile ?? this.profile,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        isUploadingImage: isUploadingImage ?? this.isUploadingImage,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        saved: saved ?? this.saved,
      );
}

final farmerProfileProvider =
    StateNotifierProvider<FarmerProfileController, FarmerProfileState>((ref) {
  return FarmerProfileController(
    profileRepo: ref.watch(farmerProfileRepositoryProvider),
    productRepo: ref.watch(farmerProductRepositoryProvider),
  );
});

class FarmerProfileController extends StateNotifier<FarmerProfileState> {
  final FarmerProfileRepository profileRepo;
  final FarmerProductRepository productRepo;

  FarmerProfileController({
    required this.profileRepo,
    required this.productRepo,
  }) : super(const FarmerProfileState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final p = await profileRepo.get();
      state = state.copyWith(profile: p, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  void edit(FarmerProfileEdit Function(FarmerProfileEdit) updater) {
    if (state.profile == null) return;
    state = state.copyWith(profile: updater(state.profile!));
  }

  Future<bool> save() async {
    if (state.profile == null) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await profileRepo.update(state.profile!);
      state = state.copyWith(isSaving: false, saved: true);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return false;
    }
  }

  Future<bool> uploadProfileImage(File file,
      {String contentType = 'image/jpeg'}) async {
    state = state.copyWith(isUploadingImage: true, clearError: true);
    try {
      final pres = await productRepo.getProfileImagePresignedUrl(
        contentType: contentType,
      );
      if (pres.uploadUrl.isEmpty) {
        state = state.copyWith(
          isUploadingImage: false,
          errorMessage:
              'Sunucuda görsel depolama yapılandırılmamış.',
        );
        return false;
      }
      await productRepo.uploadFileToPresigned(
        uploadUrl: pres.uploadUrl,
        file: file,
        contentType: contentType,
      );
      final url = pres.publicUrl ?? pres.key;
      state = state.copyWith(
        isUploadingImage: false,
        profile: state.profile?.copyWith(profileImageUrl: url),
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isUploadingImage: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'Görsel yüklenemedi',
      );
      return false;
    }
  }
}
