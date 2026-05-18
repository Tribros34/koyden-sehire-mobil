import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/category_repository.dart';
import '../models/category_model.dart';

/// Cached category tree. Invalidate to refetch.
final categoryTreeProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(categoryRepositoryProvider).getTree();
});

/// Flat list of every category (root + children) for lookup by id.
final categoryFlatProvider = Provider<List<CategoryModel>>((ref) {
  final tree = ref.watch(categoryTreeProvider).valueOrNull ?? const [];
  final out = <CategoryModel>[];
  void walk(List<CategoryModel> nodes) {
    for (final n in nodes) {
      out.add(n);
      if (n.children.isNotEmpty) walk(n.children);
    }
  }
  walk(tree);
  return out;
});

CategoryModel? findCategoryById(List<CategoryModel> flat, String id) {
  for (final c in flat) {
    if (c.id == id) return c;
  }
  return null;
}
