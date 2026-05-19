import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:koyden_sehire/app/theme.dart';
import 'package:koyden_sehire/core/utils/phone_formatter.dart';
import 'package:koyden_sehire/shared/extensions/context_extensions.dart';
import 'package:koyden_sehire/shared/widgets/app_button.dart';
import 'package:koyden_sehire/shared/widgets/app_error_widget.dart';
import 'package:koyden_sehire/shared/widgets/app_loading.dart';
import 'package:koyden_sehire/shared/widgets/founding_badge.dart';
import 'package:koyden_sehire/shared/widgets/product_card.dart';
import 'package:koyden_sehire/shared/widgets/verified_badge.dart';
import 'package:koyden_sehire/services/farmer_repository.dart';
import 'package:koyden_sehire/models/farmer_model.dart';
import 'package:koyden_sehire/controllers/public/farmer_controller.dart';

class FarmerProfileScreen extends StatefulWidget {
  final String farmerId;
  const FarmerProfileScreen({super.key, required this.farmerId});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  bool _phoneRevealed = false;
  late final FarmerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(
      FarmerController(
        Get.find<FarmerRepository>(),
        farmerId: widget.farmerId,
      ),
      tag: widget.farmerId,
    );
  }

  @override
  void dispose() {
    Get.delete<FarmerController>(tag: widget.farmerId);
    super.dispose();
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text('Üretici')),
      body: Obx(() {
        if (_ctrl.isLoadingProfile.value && _ctrl.profile.value == null) {
          return const AppLoading();
        }
        if (_ctrl.profileError.value != null && _ctrl.profile.value == null) {
          return AppErrorWidget(
            message: _ctrl.profileError.value!,
            onRetry: _ctrl.load,
          );
        }
        final p = _ctrl.profile.value;
        if (p == null) return const AppLoading();
        return ListView(
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
                  icon: const Icon(Icons.phone_outlined,
                      color: AppColors.primaryContainer),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.primaryContainer),
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
            if (_ctrl.isLoadingProducts.value)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_ctrl.productsError.value != null)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Ürünler yüklenemedi',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              )
            else if (_ctrl.products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Bu üreticinin aktif ürünü yok.',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemCount: _ctrl.products.length,
                itemBuilder: (_, i) =>
                    ProductCard(product: _ctrl.products[i]),
              ),
          ],
        );
      }),
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
          backgroundColor: AppColors.surfaceContainerLow,
          backgroundImage: profile.profileImageUrl == null
              ? null
              : CachedNetworkImageProvider(profile.profileImageUrl!),
          child: profile.profileImageUrl == null
              ? const Icon(Icons.person,
                  size: 56, color: AppColors.onSurfaceVariant)
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
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
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
