import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../shared/widgets/admin_status_badge.dart';
import '../controllers/admin_products_controller.dart';

class AdminProductsView extends ConsumerStatefulWidget {
  const AdminProductsView({super.key});

  @override
  ConsumerState<AdminProductsView> createState() =>
      _AdminProductsViewState();
}

class _AdminProductsViewState extends ConsumerState<AdminProductsView> {
  late final AdminProductsController _ctrl;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final repo = ref.read(adminRepositoryProvider);
    _ctrl = Get.put(AdminProductsController(repo));
  }

  @override
  void dispose() {
    Get.delete<AdminProductsController>();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ürün Moderasyonu',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Sisteme eklenen ürünlerin incelenmesi ve onaylanması.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Ürün, üretici veya kategori ara...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (v) => _ctrl.search.value = v,
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_ctrl.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_ctrl.error.value),
                    TextButton(
                        onPressed: _ctrl.load,
                        child: const Text('Tekrar Dene')),
                  ],
                ),
              );
            }
            final items = _ctrl.filteredItems;
            if (items.isEmpty) {
              return const Center(child: Text('Ürün bulunamadı.'));
            }
            return RefreshIndicator(
              onRefresh: _ctrl.load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final product = items[i];
                  final imageUrl = product.imageUrls.isNotEmpty
                      ? product.imageUrls.first
                      : null;
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                      color: Colors.grey[200]),
                                  errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_not_supported,
                                          size: 20)),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported,
                                      size: 20, color: Colors.grey),
                                ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          AdminStatusBadge(status: product.status),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text(
                            product.farmer?.displayName ?? '—',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            '${product.price} ₺ / ${product.unit}'
                            '${product.category != null ? ' · ${product.category!.name}' : ''}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.push('/admin/products/${product.id}'),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
