import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(apiClientProvider));
});

class CategoryRepository {
  final ApiClient _api;
  CategoryRepository(this._api);

  Future<List<CategoryModel>> getTree() {
    return _api.get(
      ApiEndpoints.categories,
      parse: (env) {
        final list = ((env as Map)['data'] as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((m) => CategoryModel.fromJson(m.cast<String, dynamic>()))
            .toList();
      },
    );
  }
}
