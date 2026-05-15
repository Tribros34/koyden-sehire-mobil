import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants.dart';
import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/farmer_card.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/shimmer_product_card.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/auth_state.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../farmers/models/farmer_model.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryTreeProvider);
    final products = ref.watch(homeNewProductsProvider);
    final farmers = ref.watch(featuredFarmersProvider) as List;
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeNewProductsProvider);
          ref.invalidate(categoryTreeProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const _HeroSearchBar(),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Kategoriler',
              onSeeAll: () => context.push('/products'),
            ),
            const SizedBox(height: 8),
            categories.when(
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Kategoriler yüklenemedi',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              data: (list) => _CategoryRow(categories: list),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Yeni Eklenenler',
              onSeeAll: () => context.push('/products'),
            ),
            const SizedBox(height: 8),
            products.when(
              loading: () => const SizedBox(
                height: 220,
                child: _HorizontalShimmer(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Ürünler yüklenemedi',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Henüz ürün bulunmuyor.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return SizedBox(
                  height: 230,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 160,
                      child: ProductCard(product: items[i], compact: true),
                    ),
                  ),
                );
              },
            ),
            if (farmers.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Öne Çıkan Üreticiler'),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: farmers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) =>
                      FarmerCard(farmer: farmers[i] as FarmerSummary),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const _PlatformInfoCard(),
            const SizedBox(height: 16),
            if (auth.status != AuthStatus.farmerActive) const _FarmerCtaCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HeroSearchBar extends StatelessWidget {
  const _HeroSearchBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.push('/search'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text(
                  'Ürün veya üretici ara...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('Tümünü Gör')),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final List<CategoryModel> categories;
  const _CategoryRow({required this.categories});
  @override
  Widget build(BuildContext context) {
    final roots = categories.where((c) => c.isRoot).toList();
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: roots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = roots[i];
          return AppCategoryChip(
            label: c.name,
            onTap: () => context.push('/products?category_id=${c.id}'),
          );
        },
      ),
    );
  }
}

class _HorizontalShimmer extends StatelessWidget {
  const _HorizontalShimmer();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => const SizedBox(
        width: 160,
        child: ShimmerProductCard(),
      ),
    );
  }
}

class _PlatformInfoCard extends StatelessWidget {
  const _PlatformInfoCard();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline, color: AppColors.primaryDark),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                AppConstants.platformInfoText,
                style: TextStyle(color: AppColors.primaryDark, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmerCtaCard extends StatelessWidget {
  const _FarmerCtaCard();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Üretici misiniz?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Davet kodunuzla başvurun ve ürünlerinizi platformda yayınlayın.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Başvur',
              onPressed: () => context.push('/apply'),
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
