import '../../products/models/farmer_product_model.dart';

class DashboardData {
  final int activeCount;
  final int pendingCount;
  final int hiddenCount;
  final int rejectedCount;
  final int inviteRemaining;
  final List<FarmerProductModel> recentProducts;

  const DashboardData({
    required this.activeCount,
    required this.pendingCount,
    required this.hiddenCount,
    required this.rejectedCount,
    required this.inviteRemaining,
    required this.recentProducts,
  });
}
