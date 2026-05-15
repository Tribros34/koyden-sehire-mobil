import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/invitation_model.dart';

final invitationRepositoryProvider =
    Provider<InvitationRepository>((ref) {
  return InvitationRepository(ref.watch(apiClientProvider));
});

class InvitationRepository {
  final ApiClient _api;
  InvitationRepository(this._api);

  Future<List<InviteCodeItem>> list() {
    return _api.get(
      ApiEndpoints.farmerInvites,
      parse: (env) {
        final list = ((env as Map)['data'] as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((m) => InviteCodeItem.fromJson(m.cast<String, dynamic>()))
            .toList();
      },
    );
  }
}
