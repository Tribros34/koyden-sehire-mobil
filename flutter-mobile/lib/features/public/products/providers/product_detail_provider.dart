import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_repository.dart';
import '../models/product_model.dart';

final productDetailProvider = FutureProvider.family
    .autoDispose<ProductModel, String>((ref, id) async {
  return ref.watch(productRepositoryProvider).getById(id);
});
