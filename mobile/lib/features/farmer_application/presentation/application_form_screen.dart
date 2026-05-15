import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/constants.dart';
import '../../../app/theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/category_chip.dart';
import '../../public/categories/providers/category_provider.dart';
import '../../public/farmers/models/farmer_model.dart';
import '../models/application_model.dart';
import '../providers/application_provider.dart';

const _stepTitles = [
  'Hesap Bilgileri',
  'Üretici Profili',
  'Üretim Bilgileri',
  'Video Doğrulama',
  'Şartlar ve Gönder',
];

class ApplicationFormScreen extends ConsumerStatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState
    extends ConsumerState<ApplicationFormScreen> {
  Future<bool> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Formu terk etmek istediğinize emin misiniz?'),
        content: const Text('Girdiğiniz bilgiler silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Terk Et'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applicationFormProvider);

    if (state.invite == null) {
      // Defensive: if user lands here without an invite, send back.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/apply');
      });
      return const Scaffold();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await _confirmExit() && mounted) {
          ref.read(applicationFormProvider.notifier).reset();
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Adım ${state.currentStep + 1} / 5'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmExit() && mounted) {
                ref.read(applicationFormProvider.notifier).reset();
                context.go('/');
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _StepIndicator(
                currentStep: state.currentStep,
                totalSteps: 5,
                title: _stepTitles[state.currentStep],
              ),
              Expanded(
                child: IndexedStack(
                  index: state.currentStep,
                  children: const [
                    _StepAccount(),
                    _StepProducer(),
                    _StepProduction(),
                    _StepVideo(),
                    _StepTerms(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

// -- STEP 1: Account info --------------------------------------------------

class _StepAccount extends ConsumerStatefulWidget {
  const _StepAccount();
  @override
  ConsumerState<_StepAccount> createState() => _StepAccountState();
}

class _StepAccountState extends ConsumerState<_StepAccount> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    final d = ref.read(applicationFormProvider).data;
    _name.text = d.fullName;
    _phone.text = d.phone;
    _email.text = d.email ?? '';
    _password.text = d.password;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(applicationFormProvider.notifier).updateData(
          (d) => d.copyWith(
            fullName: _name.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            password: _password.text,
          ),
        );
  }

  Future<void> _verifyPhone() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _save();
    final phone = _phone.text.trim();
    final verified =
        await context.push<bool>('/otp?phone=$phone') ?? false;
    if (!mounted) return;
    if (verified) {
      ref.read(applicationFormProvider.notifier).setPhoneVerified(true);
      context.toast('Telefon doğrulandı');
    }
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!ref.read(applicationFormProvider).phoneVerified) {
      context.snack('Lütfen önce telefonunuzu doğrulayın', isError: true);
      return;
    }
    _save();
    ref.read(applicationFormProvider.notifier).next();
  }

  @override
  Widget build(BuildContext context) {
    final phoneVerified =
        ref.watch(applicationFormProvider.select((s) => s.phoneVerified));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Ad Soyad',
              controller: _name,
              validator: (v) =>
                  Validators.required(v, field: 'Ad Soyad'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Telefon (05XXXXXXXXX)',
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: Validators.phone,
              suffix: phoneVerified
                  ? const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.check_circle,
                          color: AppColors.success),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            if (!phoneVerified)
              AppButton(
                label: 'Telefonu Doğrula',
                variant: AppButtonVariant.secondary,
                onPressed: _verifyPhone,
                icon: const Icon(Icons.verified_user_outlined,
                    color: AppColors.primary),
              ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'E-posta (isteğe bağlı)',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Şifre',
              controller: _password,
              obscureText: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Şifre Tekrar',
              controller: _passwordConfirm,
              obscureText: true,
              validator: Validators.confirmPassword(() => _password.text),
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Devam Et', onPressed: _continue),
          ],
        ),
      ),
    );
  }
}

// -- STEP 2: Producer profile ---------------------------------------------

class _StepProducer extends ConsumerStatefulWidget {
  const _StepProducer();
  @override
  ConsumerState<_StepProducer> createState() => _StepProducerState();
}

class _StepProducerState extends ConsumerState<_StepProducer> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _village = TextEditingController();
  final _bio = TextEditingController();
  String? _producerType;

  @override
  void initState() {
    super.initState();
    final d = ref.read(applicationFormProvider).data;
    _businessName.text = d.businessName;
    _city.text = d.city;
    _district.text = d.district;
    _village.text = d.village;
    _bio.text = d.bio;
    _producerType = d.producerType;
  }

  @override
  void dispose() {
    _businessName.dispose();
    _city.dispose();
    _district.dispose();
    _village.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(applicationFormProvider.notifier).updateData(
          (d) => d.copyWith(
            businessName: _businessName.text.trim(),
            producerType: _producerType,
            city: _city.text.trim(),
            district: _district.text.trim(),
            village: _village.text.trim(),
            bio: _bio.text.trim(),
          ),
        );
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_producerType == null) {
      context.snack('Üretici tipi seçin', isError: true);
      return;
    }
    _save();
    ref.read(applicationFormProvider.notifier).next();
  }

  void _back() {
    _save();
    ref.read(applicationFormProvider.notifier).previous();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Üretici / İşletme Adı',
              hint: "Mehmet Amca'nın Çiftliği",
              controller: _businessName,
              validator: (v) =>
                  Validators.required(v, field: 'İşletme adı'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _producerType,
              decoration: const InputDecoration(labelText: 'Üretici Tipi'),
              items: producerTypeLabels.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _producerType = v),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'İl',
              controller: _city,
              validator: (v) => Validators.required(v, field: 'İl'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'İlçe',
              controller: _district,
              validator: (v) => Validators.required(v, field: 'İlçe'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Köy / Mahalle',
              controller: _village,
              validator: (v) =>
                  Validators.required(v, field: 'Köy/Mahalle'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Kısa Biyografi',
              hint:
                  "Bursa Kestel'de ailemizle birlikte çilek ve sebze üretimi yapıyoruz.",
              controller: _bio,
              maxLines: 4,
              validator: (v) => Validators.required(v, field: 'Biyografi'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Geri',
                    variant: AppButtonVariant.secondary,
                    onPressed: _back,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(label: 'Devam Et', onPressed: _continue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -- STEP 3: Production info ----------------------------------------------

class _StepProduction extends ConsumerStatefulWidget {
  const _StepProduction();
  @override
  ConsumerState<_StepProduction> createState() => _StepProductionState();
}

class _StepProductionState extends ConsumerState<_StepProduction> {
  final _formKey = GlobalKey<FormState>();
  final _examples = TextEditingController();
  final _note = TextEditingController();
  Set<String> _selectedSlugs = {};
  String? _placeType;

  @override
  void initState() {
    super.initState();
    final d = ref.read(applicationFormProvider).data;
    _examples.text = d.productExamples;
    _note.text = d.applicationNote ?? '';
    _selectedSlugs = d.productCategorySlugs.toSet();
    _placeType = d.productionPlaceType;
  }

  @override
  void dispose() {
    _examples.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(applicationFormProvider.notifier).updateData(
          (d) => d.copyWith(
            productCategorySlugs: _selectedSlugs.toList(),
            productExamples: _examples.text.trim(),
            productionPlaceType: _placeType,
            applicationNote:
                _note.text.trim().isEmpty ? null : _note.text.trim(),
          ),
        );
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSlugs.isEmpty) {
      context.snack('En az bir kategori seçin', isError: true);
      return;
    }
    _save();
    ref.read(applicationFormProvider.notifier).next();
  }

  void _back() {
    _save();
    ref.read(applicationFormProvider.notifier).previous();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryTreeProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ürün Kategorileri',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            categories.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Kategoriler yüklenemedi',
                  style: TextStyle(color: AppColors.textSecondary)),
              data: (list) {
                final roots = list.where((c) => c.isRoot).toList();
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: roots.map((c) {
                    final selected = _selectedSlugs.contains(c.slug);
                    return AppCategoryChip(
                      label: c.name,
                      selected: selected,
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedSlugs.remove(c.slug);
                        } else {
                          _selectedSlugs.add(c.slug);
                        }
                      }),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Ürün Örnekleri',
              hint: 'Çilek, domates, salatalık, köy yumurtası',
              controller: _examples,
              maxLines: 2,
              validator: (v) =>
                  Validators.required(v, field: 'Ürün örnekleri'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _placeType,
              decoration:
                  const InputDecoration(labelText: 'Üretim Yeri (isteğe bağlı)'),
              items: productionPlaceLabels.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _placeType = v),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Başvuru Notu (isteğe bağlı)',
              hint: 'Eklemek istediğiniz bilgiler...',
              controller: _note,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Geri',
                    variant: AppButtonVariant.secondary,
                    onPressed: _back,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(label: 'Devam Et', onPressed: _continue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -- STEP 4: Video verification (optional) --------------------------------

class _StepVideo extends ConsumerStatefulWidget {
  const _StepVideo();
  @override
  ConsumerState<_StepVideo> createState() => _StepVideoState();
}

class _StepVideoState extends ConsumerState<_StepVideo> {
  File? _videoFile;
  int? _videoSize;

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 90),
      );
      if (picked == null) return;
      final file = File(picked.path);
      final size = await file.length();
      if (size > AppConstants.maxApplicationVideoBytes) {
        if (!mounted) return;
        context.snack(
          'Video boyutu 50 MB\'ı aşıyor. Lütfen daha kısa bir video seçin.',
          isError: true,
        );
        return;
      }
      setState(() {
        _videoFile = file;
        _videoSize = size;
      });
    } catch (_) {
      if (mounted) context.snack('Video seçilemedi', isError: true);
    }
  }

  Future<void> _upload() async {
    final file = _videoFile;
    if (file == null) return;
    final ok = await ref
        .read(applicationFormProvider.notifier)
        .uploadVideo(file);
    if (!mounted) return;
    if (ok) {
      context.toast('Video yüklendi');
      ref.read(applicationFormProvider.notifier).next();
    } else {
      final err = ref.read(applicationFormProvider).errorMessage;
      if (err != null) context.snack(err, isError: true);
    }
  }

  void _skip() {
    ref.read(applicationFormProvider.notifier).updateData(
          (d) => d.copyWith(clearVideoKey: true),
        );
    ref.read(applicationFormProvider.notifier).next();
  }

  void _back() => ref.read(applicationFormProvider.notifier).previous();

  String _bytesPretty(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applicationFormProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Başvurunuzu daha güvenli ve hızlı değerlendirebilmemiz için kısa bir tanışma videosu yükleyebilirsiniz.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Videoda ne söylenmeli?',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(
                  'Adınızı, nerede üretim yaptığınızı ve hangi ürünleri ürettiğinizi söylemeniz yeterlidir. Mümkünse ürünlerinizi, bahçenizi veya üretim alanınızı da gösterebilirsiniz.',
                ),
                SizedBox(height: 8),
                Text('• 30-60 saniye önerilen, maksimum 90 saniye'),
                Text('• Maksimum 50 MB'),
                Text('• MP4 veya MOV formatı'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_videoFile == null) ...[
            AppButton(
              label: 'Kameradan Çek',
              icon: const Icon(Icons.videocam_outlined, color: Colors.white),
              onPressed: () => _pickVideo(ImageSource.camera),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Galeriden Seç',
              variant: AppButtonVariant.secondary,
              icon: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              onPressed: () => _pickVideo(ImageSource.gallery),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.movie_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _videoFile!.path.split('/').last,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_videoSize != null)
                          Text(
                            _bytesPretty(_videoSize!),
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: state.isUploading
                        ? null
                        : () => setState(() {
                              _videoFile = null;
                              _videoSize = null;
                            }),
                  ),
                ],
              ),
            ),
            if (state.isUploading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: state.uploadProgress),
              const SizedBox(height: 4),
              Text(
                'Yükleniyor ${(state.uploadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            AppButton(
              label: 'Yükle ve Devam Et',
              isLoading: state.isUploading,
              onPressed: state.isUploading ? null : _upload,
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu video herkese açık yayınlanmaz. Yalnızca başvurunuzu değerlendiren Köyden Şehre ekibi tarafından görüntülenir.',
                    style: TextStyle(color: AppColors.primaryDark, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Geri',
                  variant: AppButtonVariant.secondary,
                  onPressed: state.isUploading ? null : _back,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Şimdilik Geç',
                  variant: AppButtonVariant.text,
                  onPressed: state.isUploading ? null : _skip,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -- STEP 5: Terms & submit -----------------------------------------------

class _StepTerms extends ConsumerStatefulWidget {
  const _StepTerms();
  @override
  ConsumerState<_StepTerms> createState() => _StepTermsState();
}

class _StepTermsState extends ConsumerState<_StepTerms> {
  bool _kvkk = false;
  bool _platform = false;
  bool _own = false;
  bool _location = false;
  bool _notIntermediary = false;

  @override
  void initState() {
    super.initState();
    final d = ref.read(applicationFormProvider).data;
    _kvkk = d.kvkkAccepted;
    _platform = d.platformTermsAccepted;
    _own = d.declaresOwnProduction;
    _location = d.declaresAccurateLocation;
    _notIntermediary = d.declaresNotIntermediary;
  }

  bool get _allAccepted =>
      _kvkk && _platform && _own && _location && _notIntermediary;

  Future<void> _submit() async {
    ref.read(applicationFormProvider.notifier).updateData(
          (d) => d.copyWith(
            kvkkAccepted: _kvkk,
            platformTermsAccepted: _platform,
            declaresOwnProduction: _own,
            declaresAccurateLocation: _location,
            declaresNotIntermediary: _notIntermediary,
          ),
        );
    final ok =
        await ref.read(applicationFormProvider.notifier).submit();
    if (!mounted) return;
    if (ok) {
      context.go('/apply/success');
    } else {
      final err = ref.read(applicationFormProvider).errorMessage;
      if (err != null) context.snack(err, isError: true);
    }
  }

  void _back() => ref.read(applicationFormProvider.notifier).previous();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applicationFormProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CheckTile(
            value: _kvkk,
            onChanged: (v) => setState(() => _kvkk = v),
            text:
                'KVKK aydınlatma metnini okudum ve kabul ediyorum.',
          ),
          _CheckTile(
            value: _platform,
            onChanged: (v) => setState(() => _platform = v),
            text:
                'Köyden Şehre\'nin ödeme, sipariş, kargo veya uygulama içi mesajlaşma yapmadığını anlıyorum.',
          ),
          _CheckTile(
            value: _own,
            onChanged: (v) => setState(() => _own = v),
            text:
                'Verdiğim bilgilerin doğru olduğunu ve kendi üretimimi sattığımı onaylıyorum.',
          ),
          _CheckTile(
            value: _notIntermediary,
            onChanged: (v) => setState(() => _notIntermediary = v),
            text: 'Aracı olmadığımı beyan ediyorum.',
          ),
          _CheckTile(
            value: _location,
            onChanged: (v) => setState(() => _location = v),
            text:
                'Üretim yaptığım konum bilgilerini doğru girdiğimi onaylıyorum.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Text(
              AppConstants.platformInfoText,
              style: TextStyle(color: AppColors.primaryDark, height: 1.4),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Geri',
                  variant: AppButtonVariant.secondary,
                  onPressed: state.isSubmitting ? null : _back,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Başvuruyu Gönder',
                  isLoading: state.isSubmitting,
                  onPressed: _allAccepted && !state.isSubmitting ? _submit : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;
  const _CheckTile({
    required this.value,
    required this.onChanged,
    required this.text,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(text, style: const TextStyle(height: 1.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
