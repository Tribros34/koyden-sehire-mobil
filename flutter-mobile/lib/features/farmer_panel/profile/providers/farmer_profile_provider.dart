import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../../products/data/farmer_product_repository.dart';
import '../data/farmer_profile_repository.dart';
import '../models/farmer_profile_edit_model.dart';

class FarmerProfileController extends GetxController {
  final FarmerProfileRepository profileRepo;
  final FarmerProductRepository productRepo;

  FarmerProfileController({
    required this.profileRepo,
    required this.productRepo,
  });

  final Rxn<FarmerProfileEdit> profile = Rxn<FarmerProfileEdit>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool saved = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      profile.value = await profileRepo.get();
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void edit(FarmerProfileEdit Function(FarmerProfileEdit) updater) {
    final p = profile.value;
    if (p == null) return;
    profile.value = updater(p);
  }

  Future<bool> save() async {
    final p = profile.value;
    if (p == null) return false;
    isSaving.value = true;
    errorMessage.value = null;
    try {
      await profileRepo.update(p);
      saved.value = true;
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> uploadProfileImage(
    List<int> bytes, {
    String filename = 'photo.jpg',
    String contentType = 'image/jpeg',
  }) async {
    isUploadingImage.value = true;
    errorMessage.value = null;
    try {
      final url = await productRepo.uploadProfileImage(
        bytes,
        filename: filename,
        contentType: contentType,
      );
      profile.value = profile.value?.copyWith(profileImageUrl: url);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Görsel yüklenemedi';
      return false;
    } finally {
      isUploadingImage.value = false;
    }
  }
}
