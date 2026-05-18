import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/admin_dashboard_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../shared/widgets/admin_stat_card.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() =>
      _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  late final AdminDashboardController _ctrl;

  @override
  void initState() {
    super.initState();
    final repo = Get.find<AdminRepository>();
    _ctrl = Get.put(AdminDashboardController(repo));
  }

  @override
  void dispose() {
    Get.delete<AdminDashboardController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_ctrl.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(_ctrl.error.value),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _ctrl.load,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        );
      }

      final data = _ctrl.data.value;
      if (data == null) return const SizedBox.shrink();

      return RefreshIndicator(
        onRefresh: _ctrl.load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Sistemdeki genel operasyonel durum ve metrikler.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              _StatsGrid(stats: data.stats),
              if (data.applicationsByDay.isNotEmpty) ...[
                const SizedBox(height: 24),
                _ApplicationsChart(points: data.applicationsByDay),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'Bekleyen Başvurular',
        stats.pendingApplications,
        Icons.access_time_outlined,
        stats.todayApplications > 0 ? '+${stats.todayApplications} bugün' : null,
      ),
      ('Aktif Çiftçiler', stats.activeFarmers, Icons.people_outline, null),
      (
        'Bekleyen Ürünler',
        stats.pendingProducts,
        Icons.shield_outlined,
        null
      ),
      ('Yayındaki Ürünler', stats.activeProducts, Icons.check_circle_outline,
          null),
      (
        'Askıya Alınanlar',
        stats.suspendedFarmers,
        Icons.warning_amber_outlined,
        null
      ),
      (
        'Bugünkü Başvurular',
        stats.todayApplications,
        Icons.trending_up,
        null
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards
          .map((c) => AdminStatCard(
                title: c.$1,
                value: c.$2,
                icon: c.$3,
                trend: c.$4,
              ))
          .toList(),
    );
  }
}

class _ApplicationsChart extends StatelessWidget {
  final List<ChartPoint> points;
  const _ApplicationsChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Başvuru Trendi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            points[i].name,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.value))
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFF10B981),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            const Color(0xFF10B981).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
