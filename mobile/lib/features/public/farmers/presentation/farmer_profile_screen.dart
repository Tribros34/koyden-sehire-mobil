import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/founding_badge.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/verified_badge.dart';
import '../models/farmer_model.dart';
import '../providers/farmer_provider.dart';

class FarmerProfileScreen extends ConsumerStatefulWidget {
  final String farmerId;
  const FarmerProfileScreen({super.key, required this.farmerId});

  @override
  ConsumerState<FarmerProfileScreen> createState() =>
      _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends ConsumerState<FarmerProfileScreen> {
  bool _phoneRevealed = false;

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: phone));
      if (mounted) context.toast('Telefon panoya kopyalandı');
    }
  }

  Future<void> _copy(String phone) async {
    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) context.toast('Telefon panoya kopyalandı');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(farmerProfileProvider(widget.farmerId));
    final products = ref.watch(farmerProductsProvider(widget.farmerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Üretici')),
      body: profile.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(farmerProfileProvider(widget.farmerId)),
        ),
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(profile: p),
            if (p.bio != null && p.bio!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Hakkında', style: context.text.titleMedium),
              const SizedBox(height: 8),
              Text(p.bio!, style: const TextStyle(height: 1.5)),
            ],
            if (p.showPhone && (p.publicPhone?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 24),
              Text('İletişim', style: context.text.titleMedium),
              const SizedBox(height: 8),
              if (!_phoneRevealed)
                AppButton(
                  label: 'İletişim Bilgisini Göster',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => setState(() => _phoneRevealed = true),
                  icon:
                      const Icon(Icons.phone_outlined, color: AppColors.primary),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          PhoneFormatter.pretty(p.publicPhone!),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Telefonu Kopyala',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _copy(p.publicPhone!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Üreticiyi Ara',
                        onPressed: () => _call(p.publicPhone!),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 24),
            Text('Ürünleri', style: context.text.titleMedium),
            const SizedBox(height: 8),
            products.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ürünler yüklenemedi',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              data: (items) => items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Bu üreticinin aktif ürünü yok.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) => ProductCard(product: items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final FarmerProfile profile;
  const _Header({required this.profile});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: AppColors.background,
          backgroundImage: profile.profileImageUrl == null
              ? null
              : CachedNetworkImageProvider(profile.profileImageUrl!),
          child: profile.profileImageUrl == null
              ? const Icon(Icons.person, size: 56, color: AppColors.textSecondary)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (profile.isFoundingFarmer) const FoundingBadge(small: false),
            if (profile.isVerified) const VerifiedBadge(small: false),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                producerTypeLabel(profile.producerType),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          [
            profile.city,
            profile.district,
            if (profile.village != null) profile.village,
          ].whereType<String>().join(' • '),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
