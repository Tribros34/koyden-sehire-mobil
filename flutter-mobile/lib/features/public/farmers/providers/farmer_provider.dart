import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product_model.dart';
import '../data/farmer_repository.dart';
import '../models/farmer_model.dart';

final farmerProfileProvider = FutureProvider.family
    .autoDispose<FarmerProfile, String>((ref, id) async {
  return ref.watch(farmerRepositoryProvider).getById(id);
});

final farmerProductsProvider = FutureProvider.family
    .autoDispose<List<ProductModel>, String>((ref, id) async {
  return ref.watch(farmerRepositoryProvider).getProducts(id);
});
