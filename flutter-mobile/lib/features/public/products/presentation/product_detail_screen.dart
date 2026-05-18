import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/constants.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/founding_badge.dart';
import '../../../../shared/widgets/image_carousel.dart';
import '../../../../shared/widgets/verified_badge.dart';
import '../../farmers/models/farmer_model.dart';
import '../models/product_model.dart';
import '../providers/product_detail_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _phoneRevealed = false;

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: phone));
      if (mounted) context.toast('Telefon panoya kopyalandı');
    }
  }

  Future<void> _copyPhone(String phone) async {
    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) context.toast('Telefon panoya kopyalandı');
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Detayı')),
      body: async.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (product) => _Body(
          product: product,
          phoneRevealed: _phoneRevealed,
          onReveal: () => setState(() => _phoneRevealed = true),
          onCall: _callPhone,
          onCopy: _copyPhone,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ProductModel product;
  final bool phoneRevealed;
  final VoidCallback onReveal;
  final Future<void> Function(String) onCall;
  final Future<void> Function(String) onCopy;

  const _Body({
    required this.product,
    required this.phoneRevealed,
    required this.onReveal,
    required this.onCall,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final farmer = product.farmer;
    return ListView(
      children: [
        ImageCarousel(imageUrls: product.imageUrls),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, style: context.text.headlineMedium),
              const SizedBox(height: 8),
              Text(
                AppFormatters.price(product.price, product.unit),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (product.categoryName != null) ...[
                const SizedBox(height: 4),
                Text(
                  product.categoryName!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _StockChip(stockStatus: product.stockStatus),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      [
                        product.city,
                        product.district,
                        if (product.village != null) product.village,
                      ].whereType<String>().join(', '),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text('Açıklama', style: context.text.titleMedium),
              const SizedBox(height: 8),
              Text(product.description, style: const TextStyle(height: 1.5)),
              if (farmer != null) ...[
                const SizedBox(height: 24),
                _FarmerCard(farmer: farmer),
              ],
              const SizedBox(height: 24),
              if (product.isAvailable) ...[
                _ContactActions(
                  publicPhone: farmer == null
                      ? null
                      : null /* phone is not in product list response;
                         handled via farmer profile fetch on Üreticiyi Gör */,
                  phoneRevealed: phoneRevealed,
                  onReveal: onReveal,
                  onCall: onCall,
                  onCopy: onCopy,
                  farmerId: farmer?.id,
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Text(
                    'Bu ürün şu an tükenmiş.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: const Text(
                  AppConstants.platformInfoText,
                  style: TextStyle(color: AppColors.primaryDark, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: const Text('Uygunsuz İçerik Bildir'),
                  onPressed: () {
                    context.toast(
                      'Bildirim alındı. Ekibimiz inceleyecek.',
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockChip extends StatelessWidget {
  final String stockStatus;
  const _StockChip({required this.stockStatus});
  @override
  Widget build(BuildContext context) {
    final available = stockStatus == 'available';
    final color = available ? AppColors.success : AppColors.textSecondary;
    final label = available
        ? 'Mevcut'
        : (stockStatus == 'limited' ? 'Sınırlı' : 'Tükendi');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final FarmerSummary farmer;
  const _FarmerCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/farmers/${farmer.id}'),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.background,
              backgroundImage: farmer.profileImageUrl == null
                  ? null
                  : NetworkImage(farmer.profileImageUrl!),
              child: farmer.profileImageUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmer.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${farmer.city}, ${farmer.district}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (farmer.isFoundingFarmer) const FoundingBadge(),
                      if (farmer.isVerified) const VerifiedBadge(),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ContactActions extends ConsumerWidget {
  final String? publicPhone;
  final bool phoneRevealed;
  final VoidCallback onReveal;
  final Future<void> Function(String) onCall;
  final Future<void> Function(String) onCopy;
  final String? farmerId;

  const _ContactActions({
    required this.publicPhone,
    required this.phoneRevealed,
    required this.onReveal,
    required this.onCall,
    required this.onCopy,
    required this.farmerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The product list endpoint doesn't include public_phone reliably,
    // so we always direct to the farmer profile for full contact info.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (farmerId != null)
          AppButton(
            label: 'Üreticiyi Gör',
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => context.push('/farmers/$farmerId'),
          ),
        const SizedBox(height: 8),
        if (publicPhone != null) ...[
          if (!phoneRevealed)
            AppButton(
              label: 'İletişim Bilgisini Göster',
              variant: AppButtonVariant.secondary,
              onPressed: onReveal,
              icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
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
                      PhoneFormatter.pretty(publicPhone!),
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
                    onPressed: () => onCopy(publicPhone!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Üreticiyi Ara',
                    onPressed: () => onCall(publicPhone!),
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}
