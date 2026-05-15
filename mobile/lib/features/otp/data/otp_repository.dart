import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepository(ref.watch(apiClientProvider));
});

class OtpRepository {
  final ApiClient _api;
  OtpRepository(this._api);

  Future<void> send(String phone) async {
    await _api.post(
      ApiEndpoints.otpSend,
      data: {'phone': phone},
      parse: (_) => null,
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
