import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../profile/providers/farmer_profile_provider.dart';
import '../../products/models/farmer_product_model.dart';
import '../models/dashboard_model.dart';
import '../providers/dashboard_provider.dart';

class FarmerDashboardScreen extends ConsumerWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final profile = ref.watch(farmerProfileProvider).profile;
    final displayName = profile?.displayName ??
        ref.watch(authProvider).displayName ??
        'Üretici';

    return Scaffold(
      appBar: AppBar(
        title: Text('Merhaba, $displayName'),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.background,
              backgroundImage: profile?.profileImageUrl == null
                  ? null
                  : CachedNetworkImageProvider(profile!.profileImageUrl!),
              child: profile?.profileImageUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            onPressed: () => context.push('/farmer/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          await Future.delayed(const Duration(milliseconds: 200));
        },
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(dashboardProvider),
          ),
          data: (data) => _Body(data: data),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final DashboardData data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _StatCard(
              label: 'Aktif Ürünler',
              value: data.activeCount,
              color: AppColors.success,
              icon: Icons.check_circle_outline,
            ),
            _StatCard(
              label: 'Bekleyen',
              value: data.pendingCount,
              color: AppColors.warning,
              icon: Icons.hourglass_bottom,
            ),
            _StatCard(
              label: 'Pasif',
              value: data.hiddenCount,
              color: AppColors.textSecondary,
              icon: Icons.visibility_off_outlined,
            ),
            _StatCard(
              label: 'Davet Hakkı',
              value: data.inviteRemaining,
              color: AppColors.primary,
              icon: Icons.card_giftcard_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _QuickActions(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Son Ürünlerim',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/farmer/products'),
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (data.recentProducts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Henüz ürün eklemediniz.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...data.recentProducts.map((p) => _RecentProductTile(product: p)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Yeni Ürün Ekle',
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => context.push('/farmer/products/new'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Profil',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/farmer/profile'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: 'Davetler',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/farmer/invites'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentProductTile extends StatelessWidget {
  final FarmerProductModel product;
  const _RecentProductTile({required this.product});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => context.push('/farmer/products/${product.id}/edit'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: product.imageUrls.isEmpty
                    ? Container(
                        color: AppColors.background,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.textSecondary),
                      )
                    : CachedNetworkImage(
                        imageUrl: product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.background),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(AppFormatters.price(product.price, product.unit),
                      style: const TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            _StatusBadge(status: product.status),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
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
