import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/farmer_profile_edit_model.dart';

final farmerProfileRepositoryProvider =
    Provider<FarmerProfileRepository>((ref) {
  return FarmerProfileRepository(ref.watch(apiClientProvider));
});

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
