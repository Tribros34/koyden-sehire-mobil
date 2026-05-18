class DashboardStats {
  final int pendingApplications;
  final int activeFarmers;
  final int pendingProducts;
  final int activeProducts;
  final int suspendedFarmers;
  final int todayApplications;

  const DashboardStats({
    required this.pendingApplications,
    required this.activeFarmers,
    required this.pendingProducts,
    required this.activeProducts,
    required this.suspendedFarmers,
    required this.todayApplications,
  });
}

class ChartPoint {
  final String name;
  final double value;

  const ChartPoint({required this.name, required this.value});
}

class AdminDashboardData {
  final DashboardStats stats;
  final List<ChartPoint> applicationsByDay;
  final List<ChartPoint> productsByCategory;
  final List<ChartPoint> producersByCity;

  const AdminDashboardData({
    required this.stats,
    required this.applicationsByDay,
    required this.productsByCategory,
    required this.producersByCity,
  });
}
