import 'package:koyden_sehire/core/api/api_client.dart';
import 'package:koyden_sehire/core/api/api_endpoints.dart';
import 'package:koyden_sehire/models/farmer_profile_edit_model.dart';

class FarmerProfileRepository {
  final ApiClient _api;
  FarmerProfileRepository(this._api);

  Future<FarmerProfileEdit> get() {
    return _api.get(
      ApiEndpoints.farmerProfile,
      parse: (env) {
        final data = ((env as Map)['data'] as Map?)?.cast<String, dynamic>() ??
            const {};
        return FarmerProfileEdit.fromJson(data);
      },
    );
  }

  Future<void> update(FarmerProfileEdit profile) async {
    await _api.put(
      ApiEndpoints.farmerProfile,
      data: profile.toJson(),
      parse: (_) => null,
    );
  }
}
