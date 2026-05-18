import 'package:koyden_sehire/core/api/api_client.dart';
import 'package:koyden_sehire/core/api/api_endpoints.dart';
import 'package:koyden_sehire/models/auth/login_request.dart';
import 'package:koyden_sehire/models/auth/login_response.dart';

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
