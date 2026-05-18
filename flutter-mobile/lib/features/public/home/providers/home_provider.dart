import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/data/product_repository.dart';
import '../../products/models/product_model.dart';

/// Newest products for the home feed.
final homeNewProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final res = await ref
      .watch(productRepositoryProvider)
      .list(filter: const ProductFilter(), page: 1, limit: 10);
  return res.items;
});

/// Featured-farmers section: derive unique farmers from latest products
/// because the backend has no `GET /farmers` list endpoint.
final featuredFarmersProvider = Provider((ref) {
  final products = ref.watch(homeNewProductsProvider).valueOrNull ?? const [];
  final seen = <String>{};
  final farmers = <dynamic>[];
  for (final p in products) {
    final f = p.farmer;
    if (f == null) continue;
    if (seen.add(f.id)) farmers.add(f);
    if (farmers.length >= 8) break;
  }
  return farmers;
});
