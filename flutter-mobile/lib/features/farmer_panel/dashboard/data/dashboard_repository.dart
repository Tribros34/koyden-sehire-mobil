import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../products/data/farmer_product_repository.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient api;
  final FarmerProductRepository products;
  DashboardRepository({required this.api, required this.products});

  /// Backend has no `/farmer/dashboard` endpoint per the API reference,
  /// so we derive stats from `/farmer/products` + `/farmer/invites`.
  Future<DashboardData> load() async {
    final all = await products.list(status: null);
    final activeCount = all.where((p) => p.status == 'active').length;
    final pendingCount = all.where((p) => p.status == 'pending').length;
    final hiddenCount = all.where((p) => p.status == 'hidden').length;
    final rejectedCount = all.where((p) => p.status == 'rejected').length;

    int inviteRemaining = 0;
    try {
      final invites = await api.get(
        ApiEndpoints.farmerInvites,
        parse: (env) {
          final list = ((env as Map)['data'] as List?) ?? const [];
          return list;
        },
      );
      for (final raw in invites) {
        if (raw is! Map) continue;
        final max = (raw['max_uses'] as num?)?.toInt() ?? 0;
        final used = (raw['used_count'] as num?)?.toInt() ?? 0;
        inviteRemaining += (max - used).clamp(0, max);
      }
    } catch (_) {
      // Non-fatal; show 0 if invites endpoint fails.
    }

    final recent = [...all]
      ..sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));

    return DashboardData(
      activeCount: activeCount,
      pendingCount: pendingCount,
      hiddenCount: hiddenCount,
      rejectedCount: rejectedCount,
      inviteRemaining: inviteRemaining,
      recentProducts: recent.take(5).toList(),
    );
  }
}
