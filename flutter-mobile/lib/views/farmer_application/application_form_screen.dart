import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:koyden_sehire/app/constants.dart';
import 'package:koyden_sehire/app/theme.dart';
import 'package:koyden_sehire/core/utils/validators.dart';
import 'package:koyden_sehire/shared/extensions/context_extensions.dart';
import 'package:koyden_sehire/shared/widgets/app_button.dart';
import 'package:koyden_sehire/shared/widgets/app_text_field.dart';
import 'package:koyden_sehire/shared/widgets/category_chip.dart';
import 'package:koyden_sehire/services/category_repository.dart';
import 'package:koyden_sehire/controllers/public/category_controller.dart';
import 'package:koyden_sehire/models/farmer_model.dart';
import 'package:koyden_sehire/controllers/application_form_controller.dart';

const _stepTitles = [
  'Hesap Bilgileri',
  'Üretici Profili',
  'Üretim Bilgileri',
  'Video Doğrulama',
  'Şartlar ve Gönder',
];

ApplicationFormController _formCtrl() => Get.find<ApplicationFormController>();

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
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
    final ctrl = _formCtrl();

    return Obx(() {
      if (ctrl.invite.value == null) {
        // Defensive: if user lands here without an invite, send back.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/apply');
        });
        return const Scaffold();
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final confirm = await _confirmExit();
          if (!confirm) return;
          if (!mounted) return;
          ctrl.reset();
          if (!mounted) return;
          if (!context.mounted) return;
          context.go('/');
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Adım ${ctrl.currentStep.value + 1} / 5'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                final confirm = await _confirmExit();
                if (!confirm) return;
                if (!context.mounted) return;
                ctrl.reset();
                if (!context.mounted) return;
                context.go('/');
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _StepIndicator(
                  currentStep: ctrl.currentStep.value,
                  totalSteps: 5,
                  title: _stepTitles[ctrl.currentStep.value],
                ),
                Expanded(
                  child: IndexedStack(
                    index: ctrl.currentStep.value,
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
    });
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
              backgroundColor: AppColors.outlineVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
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

class _StepAccount extends StatefulWidget {
  const _StepAccount();
  @override
  State<_StepAccount> createState() => _StepAccountState();
}

class _StepAccountState extends State<_StepAccount> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    final d = _formCtrl().data.value;
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
    _formCtrl().updateData(
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
    final verified = await context.push<bool>('/otp?phone=$phone') ?? false;
    if (!mounted) return;
    if (verified) {
      _formCtrl().setPhoneVerified(true);
      context.toast('Telefon doğrulandı');
    }
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_formCtrl().phoneVerified.value) {
      context.snack('Lütfen önce telefonunuzu doğrulayın', isError: true);
      return;
    }
    _save();
    _formCtrl().next();
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
              label: 'Ad Soyad',
              controller: _name,
              validator: (v) => Validators.required(v, field: 'Ad Soyad'),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final verified = _formCtrl().phoneVerified.value;
              return AppTextField(
                label: 'Telefon (05XXXXXXXXX)',
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: Validators.phone,
                suffix: verified
                    ? const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.check_circle,
                            color: AppColors.success),
                      )
                    : null,
              );
            }),
            const SizedBox(height: 8),
            Obx(() {
              if (_formCtrl().phoneVerified.value) {
                return const SizedBox.shrink();
              }
              return AppButton(
                label: 'Telefonu Doğrula',
                variant: AppButtonVariant.secondary,
                onPressed: _verifyPhone,
                icon: const Icon(Icons.verified_user_outlined,
                    color: AppColors.primaryContainer),
              );
            }),
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

class _StepProducer extends StatefulWidget {
  const _StepProducer();
  @override
  State<_StepProducer> createState() => _StepProducerState();
}

class _StepProducerState extends State<_StepProducer> {
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
    final d = _formCtrl().data.value;
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
    _formCtrl().updateData(
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
    _formCtrl().next();
  }

  void _back() {
    _save();
    _formCtrl().previous();
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

class _StepProduction extends StatefulWidget {
  const _StepProduction();
  @override
  State<_StepProduction> createState() => _StepProductionState();
}

class _StepProductionState extends State<_StepProduction> {
  final _formKey = GlobalKey<FormState>();
  final _examples = TextEditingController();
  final _note = TextEditingController();
  Set<String> _selectedSlugs = {};
  String? _placeType;

  late final CategoryController _cats;

  @override
  void initState() {
    super.initState();
    _cats = Get.isRegistered<CategoryController>()
        ? Get.find<CategoryController>()
        : Get.put(CategoryController(Get.find<CategoryRepository>()),
            permanent: true);
    final d = _formCtrl().data.value;
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
    _formCtrl().updateData(
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
    _formCtrl().next();
  }

  void _back() {
    _save();
    _formCtrl().previous();
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
            const Text('Ürün Kategorileri',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() {
              if (_cats.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_cats.error.value != null) {
                return const Text(
                  'Kategoriler yüklenemedi',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                );
              }
              final roots = _cats.categories.where((c) => c.isRoot).toList();
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
            }),
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

class _StepVideo extends StatefulWidget {
  const _StepVideo();
  @override
  State<_StepVideo> createState() => _StepVideoState();
}

class _StepVideoState extends State<_StepVideo> {
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
    final ok = await _formCtrl().uploadVideo(file);
    if (!mounted) return;
    if (ok) {
      context.toast('Video yüklendi');
      _formCtrl().next();
    } else {
      final err = _formCtrl().errorMessage.value;
      if (err != null) context.snack(err, isError: true);
    }
  }

  void _skip() {
    _formCtrl().updateData(
      (d) => d.copyWith(clearVideoKey: true),
    );
    _formCtrl().next();
  }

  void _back() => _formCtrl().previous();

  String _bytesPretty(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUploading = _formCtrl().isUploading.value;
      final uploadProgress = _formCtrl().uploadProgress.value;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Başvurunuzu daha güvenli ve hızlı değerlendirebilmemiz için kısa bir tanışma videosu yükleyebilirsiniz.',
              style: TextStyle(color: AppColors.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    color: AppColors.primaryContainer),
                onPressed: () => _pickVideo(ImageSource.gallery),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.movie_outlined, color: AppColors.primaryContainer),
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
                              style: const TextStyle(
                                  color: AppColors.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: isUploading
                          ? null
                          : () => setState(() {
                                _videoFile = null;
                                _videoSize = null;
                              }),
                    ),
                  ],
                ),
              ),
              if (isUploading) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: uploadProgress),
                const SizedBox(height: 4),
                Text(
                  'Yükleniyor ${(uploadProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 12),
              AppButton(
                label: 'Yükle ve Devam Et',
                isLoading: isUploading,
                onPressed: isUploading ? null : _upload,
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, color: AppColors.primaryContainer),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu video herkese açık yayınlanmaz. Yalnızca başvurunuzu değerlendiren Köyden Şehre ekibi tarafından görüntülenir.',
                      style: TextStyle(color: AppColors.primaryContainer, height: 1.4),
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
                    onPressed: isUploading ? null : _back,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Şimdilik Geç',
                    variant: AppButtonVariant.text,
                    onPressed: isUploading ? null : _skip,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// -- STEP 5: Terms & submit -----------------------------------------------

class _StepTerms extends StatefulWidget {
  const _StepTerms();
  @override
  State<_StepTerms> createState() => _StepTermsState();
}

class _StepTermsState extends State<_StepTerms> {
  bool _kvkk = false;
  bool _platform = false;
  bool _own = false;
  bool _location = false;
  bool _notIntermediary = false;

  @override
  void initState() {
    super.initState();
    final d = _formCtrl().data.value;
    _kvkk = d.kvkkAccepted;
    _platform = d.platformTermsAccepted;
    _own = d.declaresOwnProduction;
    _location = d.declaresAccurateLocation;
    _notIntermediary = d.declaresNotIntermediary;
  }

  bool get _allAccepted =>
      _kvkk && _platform && _own && _location && _notIntermediary;

  Future<void> _submit() async {
    _formCtrl().updateData(
      (d) => d.copyWith(
        kvkkAccepted: _kvkk,
        platformTermsAccepted: _platform,
        declaresOwnProduction: _own,
        declaresAccurateLocation: _location,
        declaresNotIntermediary: _notIntermediary,
      ),
    );
    final ok = await _formCtrl().submit();
    if (!mounted) return;
    if (ok) {
      context.go('/apply/success');
    } else {
      final err = _formCtrl().errorMessage.value;
      if (err != null) context.snack(err, isError: true);
    }
  }

  void _back() => _formCtrl().previous();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSubmitting = _formCtrl().isSubmitting.value;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CheckTile(
              value: _kvkk,
              onChanged: (v) => setState(() => _kvkk = v),
              text: 'KVKK aydınlatma metnini okudum ve kabul ediyorum.',
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
                color: AppColors.primaryFixed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Text(
                AppConstants.platformInfoText,
                style: TextStyle(color: AppColors.primaryContainer, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Geri',
                    variant: AppButtonVariant.secondary,
                    onPressed: isSubmitting ? null : _back,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Başvuruyu Gönder',
                    isLoading: isSubmitting,
                    onPressed:
                        _allAccepted && !isSubmitting ? _submit : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
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

// Marker import used at top of file
// ignore: unused_element
typedef _UnusedRefRepo = CategoryRepository;
