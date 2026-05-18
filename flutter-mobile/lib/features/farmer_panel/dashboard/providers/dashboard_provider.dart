import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_repository.dart';
import '../models/dashboard_model.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  return ref.watch(dashboardRepositoryProvider).load();
});
