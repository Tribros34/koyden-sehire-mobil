import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_empty_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../models/farmer_product_model.dart';
import '../providers/my_products_provider.dart';

const _tabs = [
  ('Tümü', null),
  ('Aktif', 'active'),
  ('Beklemede', 'pending'),
  ('Pasif', 'hidden'),
  ('Reddedildi', 'rejected'),
];

class MyProductsScreen extends ConsumerStatefulWidget {
  const MyProductsScreen({super.key});

  @override
  ConsumerState<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends ConsumerState<MyProductsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return;
      ref
          .read(myProductsProvider.notifier)
          .setStatus(_tabs[_tab.index].$2);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünlerim'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/farmer/products/new'),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ürün'),
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.items.isEmpty) {
            return const AppLoading();
          }
          if (state.errorMessage != null && state.items.isEmpty) {
            return AppErrorWidget(
              message: state.errorMessage!,
              onRetry: () =>
                  ref.read(myProductsProvider.notifier).refresh(),
            );
          }
          if (state.items.isEmpty) {
            return AppEmptyWidget(
              message: 'Henüz ürün eklemediniz.',
              action: TextButton.icon(
                onPressed: () => context.push('/farmer/products/new'),
                icon: const Icon(Icons.add),
                label: const Text('İlk ürününüzü ekleyin'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(myProductsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _MyProductCard(product: state.items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _MyProductCard extends ConsumerWidget {
  final FarmerProductModel product;
  const _MyProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: product.imageUrls.isEmpty
                      ? Container(
                          color: AppColors.background,
                          child: const Icon(Icons.image_outlined,
                              color: AppColors.textSecondary),
                        )
                      : CachedNetworkImage(
                          imageUrl: product.imageUrls.first,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      AppFormatters.price(product.price, product.unit),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: product.status),
                  ],
                ),
              ),
            ],
          ),
          if (product.adminNote != null && product.adminNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      product.adminNote!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (product.status == 'active')
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      product.stockStatus == 'available'
                          ? Icons.check_circle_outline
                          : Icons.remove_circle_outline,
                      size: 18,
                    ),
                    label: Text(
                      product.stockStatus == 'available'
                          ? 'Mevcut'
                          : 'Tükendi',
                    ),
                    onPressed: () async {
                      final next = product.stockStatus == 'available'
                          ? 'out_of_stock'
                          : 'available';
                      final ok = await ref
                          .read(myProductsProvider.notifier)
                          .setStockStatus(product.id, next);
                      if (!context.mounted) return;
                      if (ok) {
                        context.toast('Stok durumu güncellendi');
                      }
                    },
                  ),
                ),
              if (product.status == 'active') const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Düzenle'),
                  onPressed: () => context
                      .push('/farmer/products/${product.id}/edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('Aktif', AppColors.success),
      'pending' => ('Beklemede', AppColors.warning),
      'rejected' => ('Reddedildi', AppColors.error),
      'hidden' => ('Pasif', AppColors.textSecondary),
      _ => (status, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
