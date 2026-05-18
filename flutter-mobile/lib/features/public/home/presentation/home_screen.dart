import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants.dart';
import '../../../../app/theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/farmer_card.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/shimmer_product_card.dart';
import '../../../auth/providers/auth_state.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../farmers/models/farmer_model.dart';
import '../../home/providers/home_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catCtrl = Get.find<CategoryController>();
    final homeCtrl = Get.find<HomeController>();
    final auth = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.eco_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          Obx(() {
            final status = auth.status.value;
            final isFarmer = status == AuthStatus.farmerActive;
            final isAdmin = status == AuthStatus.admin;
            if (isFarmer) {
              return TextButton.icon(
                onPressed: () => context.go('/farmer/dashboard'),
                icon: const Icon(Icons.dashboard_outlined, size: 18),
                label: const Text('Panelim'),
              );
            } else if (isAdmin) {
              return TextButton.icon(
                onPressed: () => context.go('/admin'),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                label: const Text('Admin'),
              );
            } else {
              return TextButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_outlined, size: 18),
                label: const Text('Giriş'),
              );
            }
          }),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Obx(() {
        final isFarmer = auth.status.value == AuthStatus.farmerActive;
        return _PublicBottomNav(isFarmer: isFarmer);
      }),
      body: RefreshIndicator(
        onRefresh: () async {
          homeCtrl.load();
          catCtrl.load();
        },
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: _HeroSearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Categories
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Kategoriler',
                onSeeAll: () => context.push('/products'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Obx(() {
                if (catCtrl.isLoading.value) {
                  return const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (catCtrl.error.value != null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Kategoriler yüklenemedi',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return _CategoryRow(categories: catCtrl.categories);
              }),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // New products
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Yeni Eklenenler',
                onSeeAll: () => context.push('/products'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Obx(() {
                if (homeCtrl.isLoading.value) {
                  return const SizedBox(
                    height: 240,
                    child: _HorizontalShimmer(),
                  );
                }
                if (homeCtrl.error.value != null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ürünler yüklenemedi',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                final items = homeCtrl.newProducts;
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Henüz ürün bulunmuyor.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return SizedBox(
                  height: 270,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 160,
                      child: ProductCard(product: items[i], compact: true),
                    ),
                  ),
                );
              }),
            ),

            // Featured farmers
            SliverToBoxAdapter(
              child: Obx(() {
                final farmers = homeCtrl.featuredFarmers;
                if (farmers.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const _SectionHeader(title: 'Öne Çıkan Üreticiler'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: farmers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            FarmerCard(farmer: farmers[i] as FarmerSummary),
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(child: _PlatformInfoCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Obx(() {
                final isFarmer =
                    auth.status.value == AuthStatus.farmerActive;
                return isFarmer
                    ? const _FarmerPanelCtaCard()
                    : const _GuestCtaCard();
              }),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PublicBottomNav extends StatelessWidget {
  final bool isFarmer;
  const _PublicBottomNav({required this.isFarmer});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (i) {
        switch (i) {
          case 0:
            break;
          case 1:
            context.push('/products');
          case 2:
            context.push('/apply');
          case 3:
            if (isFarmer) {
              context.go('/farmer/dashboard');
            } else {
              context.push('/login');
            }
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Ana Sayfa',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Ürünler',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.agriculture_outlined),
          label: 'Başvur',
        ),
        BottomNavigationBarItem(
          icon: Icon(
              isFarmer ? Icons.dashboard_outlined : Icons.login_outlined),
          activeIcon: Icon(isFarmer ? Icons.dashboard : Icons.login),
          label: isFarmer ? 'Panelim' : 'Giriş Yap',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

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
            child: const Row(
              children: [
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
            child: Text(
                title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (onSeeAll != null)
            TextButton(
                onPressed: onSeeAll, child: const Text('Tümünü Gör')),
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
        physics: const ClampingScrollPhysics(),
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
      physics: const ClampingScrollPhysics(),
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
          color: AppColors.primaryLight.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryDark),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                AppConstants.platformInfoText,
                style:
                    TextStyle(color: AppColors.primaryDark, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestCtaCard extends StatelessWidget {
  const _GuestCtaCard();
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
            Row(
              children: [
                AppButton(
                  label: 'Başvur',
                  onPressed: () => context.push('/apply'),
                  fullWidth: false,
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_outlined, size: 18),
                  label: const Text('Üretici Girişi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmerPanelCtaCard extends StatelessWidget {
  const _FarmerPanelCtaCard();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            const Icon(Icons.dashboard_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Çiftçi panelinize gitmek için tıklayın.',
                style: TextStyle(color: AppColors.primaryDark),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/farmer/dashboard'),
              child: const Text('Panelim'),
            ),
          ],
        ),
      ),
    );
  }
}
