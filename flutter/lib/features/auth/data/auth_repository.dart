import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

class AuthRepository {
  final ApiClient _api;
  AuthRepository(this._api);

  Future<LoginResponse> login(LoginRequest req) {
    return _api.post(
      ApiEndpoints.login,
      data: req.toJson(),
      parse: (env) {
        final data = (env as Map)['data'] as Map?;
        return LoginResponse.fromJson(
          (data ?? const {}).cast<String, dynamic>(),
        );
      },
    );
  }
}
