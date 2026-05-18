import 'package:koyden_sehire/core/api/api_client.dart';
import 'package:koyden_sehire/core/api/api_endpoints.dart';
import 'package:koyden_sehire/models/auth/login_request.dart';
import 'package:koyden_sehire/models/auth/login_response.dart';
import 'package:koyden_sehire/models/auth/register_customer_request.dart';

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

  /// Registers a new customer. Requires that the OTP for [req.phone]
  /// has already been verified (otp_verified key still alive in Redis).
  Future<LoginResponse> registerCustomer(RegisterCustomerRequest req) {
    return _api.post(
      ApiEndpoints.registerCustomer,
      data: req.toJson(),
      parse: (env) {
        final data = (env as Map)['data'] as Map?;
        return LoginResponse.fromJson(
          (data ?? const {}).cast<String, dynamic>(),
        );
      },
    );
  }

  /// Asks the backend to send an SMS OTP to [phone].
  /// Same endpoint is used for app-wide phone verification.
  Future<void> sendOtp(String phone) async {
    await _api.post<void>(
      ApiEndpoints.otpSend,
      data: {'phone': phone},
      parse: (_) {},
    );
  }

  /// Verifies an OTP [code] for [phone]. On success the backend marks the
  /// phone as verified for ~30 minutes so it can be consumed by register.
  Future<void> verifyOtp(String phone, String code) async {
    await _api.post<void>(
      ApiEndpoints.otpVerify,
      data: {'phone': phone, 'code': code},
      parse: (_) {},
    );
  }
}
