import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../public/farmers/models/farmer_model.dart';
import '../providers/farmer_profile_provider.dart';

class FarmerProfileEditScreen extends ConsumerStatefulWidget {
  const FarmerProfileEditScreen({super.key});

  @override
  ConsumerState<FarmerProfileEditScreen> createState() =>
      _FarmerProfileEditScreenState();
}

class _FarmerProfileEditScreenState
    extends ConsumerState<FarmerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final ok = await ref
        .read(farmerProfileProvider.notifier)
        .uploadProfileImage(File(picked.path));
    if (!mounted) return;
    if (ok) context.toast('Profil fotoğrafı güncellendi');
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(farmerProfileProvider.notifier).save();
    if (!mounted) return;
    if (ok) {
      context.toast('Profil güncellendi');
    } else {
      final err = ref.read(farmerProfileProvider).errorMessage;
      if (err != null) context.snack(err, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.profile == null) {
            return const AppLoading();
          }
          if (state.profile == null) {
            return AppErrorWidget(
              message: state.errorMessage ?? 'Profil yüklenemedi',
              onRetry: () => ref.read(farmerProfileProvider.notifier).load(),
            );
          }
          final p = state.profile!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.background,
                      backgroundImage: p.profileImageUrl == null
                          ? null
                          : CachedNetworkImageProvider(p.profileImageUrl!),
                      child: p.profileImageUrl == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: state.isUploadingImage
                              ? null
                              : _pickProfileImage,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isUploadingImage) ...[
                const SizedBox(height: 8),
                const Center(child: LinearProgressIndicator()),
              ],
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Üretici Adı',
                      initialValue: p.displayName,
                      onChanged: (v) =>
                          ref.read(farmerProfileProvider.notifier).edit(
                                (e) => e.copyWith(displayName: v),
                              ),
                      validator: (v) =>
                          Validators.required(v, field: 'Üretici adı'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: p.producerType,
                      decoration:
                          const InputDecoration(labelText: 'Üretici Tipi'),
                      items: producerTypeLabels.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) =>
                          ref.read(farmerProfileProvider.notifier).edit(
                                (e) => e.copyWith(producerType: v),
                              ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'İl',
                      initialValue: p.city,
                      onChanged: (v) =>
                          ref.read(farmerProfileProvider.notifier).edit(
                                (e) => e.copyWith(city: v),
                              ),
                      validator: (v) => Validators.required(v, field: 'İl'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'İlçe',
                      initialValue: p.district,
                      onChanged: (v) =>
                          ref.read(farmerProfileProvider.notifier).edit(
                                (e) => e.copyWith(district: v),
                              ),
                      validator: (v) => Validators.required(v, field: 'İlçe'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Köy / Mahalle',
                      initialValue: p.village,
                      onChanged: (v) =>
                          ref.read(farmerProfileProvider.notifier).edit(
                                (e) => e.copyWith(village: v),
                              ),
                      validator: (v) =>
                          Validators.required(v, field: 'Köy/Mahalle'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Biyografi',
                      initialValue: p.bio,
                      maxLines: 4,
                      onChanged: (v) =>
                          ref.read(farmerProfileProvider.notifier).edit(
                                (e) => e.copyWith(bio: v),
                              ),
                      validator: (v) =>
                          Validators.required(v, field: 'Biyografi'),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'İletişim Telefonu',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  p.publicPhone.isEmpty
                                      ? '-'
                                      : PhoneFormatter.pretty(p.publicPhone),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: p.showPhone,
                      onChanged: (v) =>
                          ref.read(farmerProfileProvider.notifier).edit(
                                (e) => e.copyWith(showPhone: v),
                              ),
                      title: const Text(
                        'Telefonum ürün sayfalarında görünsün',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Değişiklikleri Kaydet',
                      isLoading: state.isSaving,
                      onPressed: state.isSaving ? null : _save,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
