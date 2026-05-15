import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../shared/models/pagination_model.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(apiClientProvider));
});

class ProductRepository {
  final ApiClient _api;
  ProductRepository(this._api);

  Future<Paginated<ProductModel>> list({
    required ProductFilter filter,
    int page = 1,
    int limit = 20,
  }) {
    return _api.get(
      ApiEndpoints.products,
      query: filter.toQuery(page: page, limit: limit),
      parse: (env) {
        final map = (env as Map);
        final list = (map['data'] as List?) ?? const [];
        final items = list
            .whereType<Map>()
            .map((m) => ProductModel.fromJson(m.cast<String, dynamic>()))
            .toList();
        final pag = (map['pagination'] as Map?)?.cast<String, dynamic>();
        return Paginated(
          items: items,
          pagination: pag == null
              ? Pagination(
                  page: page,
                  limit: limit,
                  total: items.length,
                  totalPages: 1,
                )
              : Pagination.fromJson(pag),
        );
      },
    );
  }

  Future<ProductModel> getById(String id) {
    return _api.get(
      ApiEndpoints.productById(id),
      parse: (env) {
        final data = ((env as Map)['data'] as Map?)?.cast<String, dynamic>() ??
            const {};
        return ProductModel.fromJson(data);
      },
    );
  }
}
