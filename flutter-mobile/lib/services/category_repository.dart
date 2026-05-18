import 'package:koyden_sehire/core/api/api_client.dart';
import 'package:koyden_sehire/core/api/api_endpoints.dart';
import 'package:koyden_sehire/models/category_model.dart';

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
