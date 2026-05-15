import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/error_handler.dart';
import '../models/farmer_product_model.dart';

final farmerProductRepositoryProvider =
    Provider<FarmerProductRepository>((ref) {
  return FarmerProductRepository(ref.watch(apiClientProvider));
});

class FarmerProductRepository {
  final ApiClient _api;
  FarmerProductRepository(this._api);

  Future<List<FarmerProductModel>> list({String? status}) {
    return _api.get(
      ApiEndpoints.farmerProducts2,
      query: status == null ? null : {'status': status},
      parse: (env) {
        final list = ((env as Map)['data'] as List?) ?? const [];
        return list
            .whereType<Map>()
            .map(
              (m) => FarmerProductModel.fromJson(m.cast<String, dynamic>()),
            )
            .toList();
      },
    );
  }

  Future<FarmerProductModel> getById(String id) {
    return _api.get(
      ApiEndpoints.farmerProduct(id),
      parse: (env) {
        final data = ((env as Map)['data'] as Map?)?.cast<String, dynamic>() ??
            const {};
        return FarmerProductModel.fromJson(data);
      },
    );
  }

  Future<void> create(ProductFormData data) async {
    await _api.post(
      ApiEndpoints.farmerProducts2,
      data: data.toJson(),
      parse: (_) => null,
    );
  }

  Future<void> update(String id, ProductFormData data) async {
    await _api.put(
      ApiEndpoints.farmerProduct(id),
      data: data.toJson(),
      parse: (_) => null,
    );
  }

  Future<void> setStockStatus(String id, String stockStatus) async {
    await _api.patch(
      ApiEndpoints.farmerProductStatus(id),
      data: {'stock_status': stockStatus},
      parse: (_) => null,
    );
  }

  /// Returns (uploadUrl, key, publicUrl).
  Future<({String uploadUrl, String key, String? publicUrl})>
      getProductImagePresignedUrl({String contentType = 'image/jpeg'}) {
    return _api.post(
      ApiEndpoints.uploadProductImage,
      data: {'content_type': contentType},
      parse: (env) {
        final data = ((env as Map)['data'] as Map?)?.cast<String, dynamic>() ??
            const {};
        return (
          uploadUrl: data['upload_url']?.toString() ?? '',
          key: data['key']?.toString() ?? '',
          publicUrl: data['public_url']?.toString(),
        );
      },
    );
  }

  Future<({String uploadUrl, String key, String? publicUrl})>
      getProfileImagePresignedUrl({String contentType = 'image/jpeg'}) {
    return _api.post(
      ApiEndpoints.uploadProfileImage,
      data: {'content_type': contentType},
      parse: (env) {
        final data = ((env as Map)['data'] as Map?)?.cast<String, dynamic>() ??
            const {};
        return (
          uploadUrl: data['upload_url']?.toString() ?? '',
          key: data['key']?.toString() ?? '',
          publicUrl: data['public_url']?.toString(),
        );
      },
    );
  }

  Future<void> uploadFileToPresigned({
    required String uploadUrl,
    required File file,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) async {
    final dio = Dio();
    try {
      final length = await file.length();
      final stream = file.openRead();
      await dio.put(
        uploadUrl,
        data: stream,
        onSendProgress: onProgress,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: contentType,
            HttpHeaders.contentLengthHeader: length,
          },
        ),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
