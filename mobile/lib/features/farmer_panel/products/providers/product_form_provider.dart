import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../data/farmer_product_repository.dart';
import '../models/farmer_product_model.dart';

class ProductFormState {
  final ProductFormData data;
  final bool isSubmitting;
  final bool isUploadingImage;
  final String? errorMessage;
  final bool saved;

  const ProductFormState({
    this.data = const ProductFormData(),
    this.isSubmitting = false,
    this.isUploadingImage = false,
    this.errorMessage,
    this.saved = false,
  });

  ProductFormState copyWith({
    ProductFormData? data,
    bool? isSubmitting,
    bool? isUploadingImage,
    String? errorMessage,
    bool? saved,
    bool clearError = false,
  }) =>
      ProductFormState(
        data: data ?? this.data,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isUploadingImage: isUploadingImage ?? this.isUploadingImage,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        saved: saved ?? this.saved,
      );
}

final productFormProvider =
    StateNotifierProvider.autoDispose<ProductFormController, ProductFormState>(
        (ref) {
  return ProductFormController(ref.watch(farmerProductRepositoryProvider));
});

class ProductFormController extends StateNotifier<ProductFormState> {
  final FarmerProductRepository _repo;
  ProductFormController(this._repo) : super(const ProductFormState());

  void hydrate(FarmerProductModel m) {
    state = state.copyWith(
      data: ProductFormData(
        title: m.title,
        description: m.description,
        price: m.price.toString(),
        unit: m.unit,
        city: m.city,
        district: m.district,
        village: m.village,
        categoryId: m.categoryId,
        stockStatus: m.stockStatus,
        imageUrls: m.imageUrls,
      ),
    );
  }

  void update(ProductFormData Function(ProductFormData) updater) {
    state = state.copyWith(data: updater(state.data));
  }

  Future<bool> uploadImage(File file, {String contentType = 'image/jpeg'}) async {
    state = state.copyWith(isUploadingImage: true, clearError: true);
    try {
      final pres = await _repo.getProductImagePresignedUrl(
        contentType: contentType,
      );
      if (pres.uploadUrl.isEmpty) {
        state = state.copyWith(
          isUploadingImage: false,
          errorMessage:
              'Sunucuda görsel depolama yapılandırılmamış. Lütfen yöneticiyle iletişime geçin.',
        );
        return false;
      }
      await _repo.uploadFileToPresigned(
        uploadUrl: pres.uploadUrl,
        file: file,
        contentType: contentType,
      );
      final newUrl = pres.publicUrl ?? pres.key;
      final next = [...state.data.imageUrls, newUrl];
      state = state.copyWith(
        isUploadingImage: false,
        data: state.data.copyWith(imageUrls: next),
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

  void removeImage(int index) {
    final list = [...state.data.imageUrls]..removeAt(index);
    state = state.copyWith(data: state.data.copyWith(imageUrls: list));
  }

  Future<bool> submit({String? editingId}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      if (editingId == null) {
        await _repo.create(state.data);
      } else {
        await _repo.update(editingId, state.data);
      }
      state = state.copyWith(isSubmitting: false, saved: true);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Kaydedilemedi',
      );
      return false;
    }
  }
}
