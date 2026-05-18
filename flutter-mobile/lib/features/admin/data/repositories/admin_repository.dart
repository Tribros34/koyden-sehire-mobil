import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/admin_application_model.dart';
import '../models/admin_category_model.dart';
import '../models/admin_dashboard_model.dart';
import '../models/admin_product_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

class AdminRepository {
  final ApiClient _client;
  AdminRepository(this._client);

  Future<AdminDashboardData> getDashboard() async {
    final results = await Future.wait([
      _client.get<Map<String, dynamic>>(
        ApiEndpoints.adminApplications,
        query: {'page': 1, 'limit': 1, 'status': 'pending'},
        parse: (d) => d as Map<String, dynamic>,
      ),
      _client.get<Map<String, dynamic>>(
        ApiEndpoints.adminProducts,
        query: {'page': 1, 'limit': 1, 'status': 'pending'},
        parse: (d) => d as Map<String, dynamic>,
      ),
      _client.get<Map<String, dynamic>>(
        ApiEndpoints.adminProducts,
        query: {'page': 1, 'limit': 1, 'status': 'active'},
        parse: (d) => d as Map<String, dynamic>,
      ),
    ]);

    final pendingApps =
        (results[0]['pagination']?['total'] as num?)?.toInt() ?? 0;
    final pendingProds =
        (results[1]['pagination']?['total'] as num?)?.toInt() ?? 0;
    final activeProds =
        (results[2]['pagination']?['total'] as num?)?.toInt() ?? 0;

    return AdminDashboardData(
      stats: DashboardStats(
        pendingApplications: pendingApps,
        activeFarmers: 0,
        pendingProducts: pendingProds,
        activeProducts: activeProds,
        suspendedFarmers: 0,
        todayApplications: 0,
      ),
      applicationsByDay: [],
      productsByCategory: [],
      producersByCity: [],
    );
  }

  Future<List<AdminApplication>> getApplications({String? status}) async {
    return _client.get<List<AdminApplication>>(
      ApiEndpoints.adminApplications,
      query: {
        if (status != null) 'status': status,
        'limit': 100,
      },
      parse: (d) {
        final list = (d['data'] ?? d) as List?;
        return (list ?? [])
            .map((e) => AdminApplication.fromJson(
                (e as Map).cast<String, dynamic>()))
            .toList();
      },
    );
  }

  Future<AdminApplication> getApplication(String id) async {
    return _client.get<AdminApplication>(
      ApiEndpoints.adminApplication(id),
      parse: (d) =>
          AdminApplication.fromJson((d['data'] as Map).cast<String, dynamic>()),
    );
  }

  Future<void> reviewApplication(
    String id,
    String action, {
    String? reason,
  }) async {
    final body = action == 'approve'
        ? {'is_founding_farmer': false, 'invite_quota': 3}
        : {'reason': reason ?? ''};
    await _client.post<void>(
      ApiEndpoints.adminApplicationAction(id, action),
      data: body,
      parse: (_) {},
    );
  }

  Future<List<AdminProduct>> getProducts({String? status}) async {
    return _client.get<List<AdminProduct>>(
      ApiEndpoints.adminProducts,
      query: {
        if (status != null) 'status': status,
        'limit': 100,
      },
      parse: (d) {
        final list = (d['data'] ?? d) as List?;
        return (list ?? [])
            .map((e) =>
                AdminProduct.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      },
    );
  }

  Future<AdminProduct> getProduct(String id) async {
    return _client.get<AdminProduct>(
      ApiEndpoints.adminProduct(id),
      parse: (d) =>
          AdminProduct.fromJson((d['data'] as Map).cast<String, dynamic>()),
    );
  }

  Future<void> moderateProduct(
    String id,
    String action, {
    String? reason,
  }) async {
    final body = action == 'reject' ? {'reason': reason ?? ''} : <String, dynamic>{};
    await _client.post<void>(
      ApiEndpoints.adminProductAction(id, action),
      data: body,
      parse: (_) {},
    );
  }

  Future<List<AdminCategory>> getCategories() async {
    return _client.get<List<AdminCategory>>(
      ApiEndpoints.adminCategories,
      parse: (d) {
        final list = (d['data'] ?? d) as List?;
        return (list ?? [])
            .map((e) => AdminCategory.fromJson(
                (e as Map).cast<String, dynamic>()))
            .toList();
      },
    );
  }
}
