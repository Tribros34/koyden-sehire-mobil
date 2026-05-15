import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/invitation_repository.dart';
import '../models/invitation_model.dart';

final invitationListProvider =
    FutureProvider<List<InviteCodeItem>>((ref) async {
  return ref.watch(invitationRepositoryProvider).list();
});
