import 'package:koyden_sehire/core/api/api_client.dart';
import 'package:koyden_sehire/core/api/api_endpoints.dart';
import 'package:koyden_sehire/models/product_model.dart';
import 'package:koyden_sehire/models/farmer_model.dart';

class FarmerRepository {
  final ApiClient _api;
  FarmerRepository(this._api);

  Future<FarmerProfile> getById(String id) {
    return _api.get(
      ApiEndpoints.farmerById(id),
      parse: (env) {
        final data = ((env as Map)['data'] as Map?)?.cast<String, dynamic>() ??
            const {};
        return FarmerProfile.fromJson(data);
      },
    );
  }

  Future<List<ProductModel>> getProducts(String farmerId) {
    return _api.get(
      ApiEndpoints.farmerProducts(farmerId),
      parse: (env) {
        final list = ((env as Map)['data'] as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((m) => ProductModel.fromJson(m.cast<String, dynamic>()))
            .toList();
      },
    );
  }
}
