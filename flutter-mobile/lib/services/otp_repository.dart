import 'package:flutter/foundation.dart';
import 'package:koyden_sehire/core/api/api_client.dart';
import 'package:koyden_sehire/core/api/api_endpoints.dart';

class OtpRepository {
  final ApiClient _api;
  OtpRepository(this._api);

  Future<void> send(String phone) async {
    await _api.post(
      ApiEndpoints.otpSend,
      data: {'phone': phone},
      parse: (data) {
        final devCode = data['dev_code'];
        if (devCode != null) {
          debugPrint('[DEV] OTP kodu: $devCode');
        }
        return null;
      },
    );
  }

  Future<void> verify({required String phone, required String code}) async {
    await _api.post(
      ApiEndpoints.otpVerify,
      data: {'phone': phone, 'code': code},
      parse: (_) => null,
    );
  }
}
