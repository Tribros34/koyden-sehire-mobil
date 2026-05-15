import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/constants.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../public/categories/models/category_model.dart';
import '../../../public/categories/providers/category_provider.dart';
import '../../profile/providers/farmer_profile_provider.dart';
import '../models/farmer_product_model.dart';
import '../providers/my_products_provider.dart';
import '../providers/product_form_provider.dart';
import '../data/farmer_product_repository.dart';

/// Used by both add and edit. Pass `editingId` to load + update.
class ProductFormScreen extends ConsumerStatefulWidget {
  final String? editingId;
  const ProductFormScreen({super.key, this.editingId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  bool _loadingExisting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    if (_initialized) return;
    final notifier = ref.read(productFormProvider.notifier);

    if (widget.editingId != null) {
      setState(() => _loadingExisting = true);
      try {
        final m = await ref
            .read(farmerProductRepositoryProvider)
            .getById(widget.editingId!);
        notifier.hydrate(m);
      } catch (e) {
        setState(() => _loadError = e.toString());
      } finally {
        if (mounted) setState(() => _loadingExisting = false);
      }
    } else {
      // Pre-fill location from farmer profile.
      final p = ref.read(farmerProfileProvider).profile;
      if (p != null) {
        notifier.update((d) => d.copyWith(
              city: p.city,
              district: p.district,
              village: p.village,
            ));
      }
    }
    _initialized = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    final state = ref.read(productFormProvider);
    if (state.data.imageUrls.length >= AppConstants.maxProductImages) {
      context.snack(
        'En fazla ${AppConstants.maxProductImages} fotoğraf ekleyebilirsiniz',
        isError: true,
      );
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;
    final ok = await ref
        .read(productFormProvider.notifier)
        .uploadImage(File(picked.path));
    if (!mounted) return;
    if (!ok) {
      final err = ref.read(productFormProvider).errorMessage;
      if (err != null) context.snack(err, isError: true);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Kameradan Çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final data = ref.read(productFormProvider).data;
    if (data.categoryId == null) {
      context.snack('Kategori seçin', isError: true);
      return;
    }
    if (data.imageUrls.isEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Fotoğrafsız devam et?'),
          content: const Text(
            'Fotoğraf eklemeniz ürününüzün daha iyi görünmesini sağlar. '
            'Yine de devam etmek ister misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Devam Et'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }
    final ok = await ref
        .read(productFormProvider.notifier)
        .submit(editingId: widget.editingId);
    if (!mounted) return;
    if (ok) {
      context.toast(widget.editingId == null
          ? 'Ürününüz incelemeye alındı.'
          : 'Ürün güncellendi.');
      ref.invalidate(myProductsProvider);
      context.go('/farmer/products');
    } else {
      final err = ref.read(productFormProvider).errorMessage;
      if (err != null) context.snack(err, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormProvider);
    final categories = ref.watch(categoryTreeProvider);

    if (_loadingExisting) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ürün Düzenle')),
        body: const AppLoading(),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ürün Düzenle')),
        body: AppErrorWidget(
          message: _loadError!,
          onRetry: () {
            setState(() {
              _loadError = null;
              _initialized = false;
            });
            _initializeForm();
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingId == null ? 'Yeni Ürün' : 'Ürünü Düzenle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ImagePickerSection(
                  imageUrls: state.data.imageUrls,
                  isUploading: state.isUploadingImage,
                  onAdd: _showImageSourceSheet,
                  onRemove: (i) =>
                      ref.read(productFormProvider.notifier).removeImage(i),
                ),
                const SizedBox(height: 16),
                categories.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(
                    'Kategoriler yüklenemedi',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  data: (list) =>
                      _CategorySelector(categories: list, selected: state.data),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Ürün Adı',
                  hint: 'Günlük Köy Çileği',
                  initialValue: state.data.title,
                  maxLength: 255,
                  onChanged: (v) => ref
                      .read(productFormProvider.notifier)
                      .update((d) => d.copyWith(title: v)),
                  validator: (v) => Validators.required(v, field: 'Ürün adı'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Açıklama',
                  hint: 'Ürününüzü tanıtın...',
                  initialValue: state.data.description,
                  maxLines: 5,
                  onChanged: (v) => ref
                      .read(productFormProvider.notifier)
                      .update((d) => d.copyWith(description: v)),
                  validator: (v) =>
                      Validators.required(v, field: 'Açıklama'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Fiyat',
                        prefix: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('₺',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        initialValue: state.data.price,
                        onChanged: (v) => ref
                            .read(productFormProvider.notifier)
                            .update((d) => d.copyWith(price: v)),
                        validator: Validators.positiveNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: state.data.unit,
                        decoration: const InputDecoration(labelText: 'Birim'),
                        items: productUnits
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          ref
                              .read(productFormProvider.notifier)
                              .update((d) => d.copyWith(unit: v));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StockToggle(
                  current: state.data.stockStatus,
                  onChanged: (v) => ref
                      .read(productFormProvider.notifier)
                      .update((d) => d.copyWith(stockStatus: v)),
                ),
                const SizedBox(height: 16),
                Text('Konum', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                AppTextField(
                  label: 'İl',
                  initialValue: state.data.city,
                  onChanged: (v) => ref
                      .read(productFormProvider.notifier)
                      .update((d) => d.copyWith(city: v)),
                  validator: (v) => Validators.required(v, field: 'İl'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'İlçe',
                  initialValue: state.data.district,
                  onChanged: (v) => ref
                      .read(productFormProvider.notifier)
                      .update((d) => d.copyWith(district: v)),
                  validator: (v) => Validators.required(v, field: 'İlçe'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Köy / Mahalle',
                  initialValue: state.data.village,
                  onChanged: (v) => ref
                      .read(productFormProvider.notifier)
                      .update((d) => d.copyWith(village: v)),
                  validator: (v) =>
                      Validators.required(v, field: 'Köy/Mahalle'),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: widget.editingId == null
                      ? 'Ürünü Yayına Gönder'
                      : 'Değişiklikleri Kaydet',
                  isLoading: state.isSubmitting,
                  onPressed: state.isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final List<String> imageUrls;
  final bool isUploading;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _ImagePickerSection({
    required this.imageUrls,
    required this.isUploading,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ürün Fotoğrafları (${imageUrls.length}/${AppConstants.maxProductImages})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              if (i == imageUrls.length) {
                return _AddImageTile(
                  onTap: isUploading ? null : onAdd,
                  isUploading: isUploading,
                );
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[i],
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.background,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isUploading;
  const _AddImageTile({required this.onTap, required this.isUploading});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: isUploading
            ? const SizedBox(
                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.add_a_photo_outlined,
                color: AppColors.textSecondary),
      ),
    );
  }
}

class _CategorySelector extends ConsumerStatefulWidget {
  final List<CategoryModel> categories;
  final ProductFormData selected;
  const _CategorySelector(
      {required this.categories, required this.selected});
  @override
  ConsumerState<_CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<_CategorySelector> {
  String? _mainId;

  @override
  void initState() {
    super.initState();
    final flat = ref.read(categoryFlatProvider);
    final selectedId = widget.selected.categoryId;
    if (selectedId != null) {
      final cat = findCategoryById(flat, selectedId);
      _mainId = cat?.parentId ?? cat?.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roots = widget.categories.where((c) => c.isRoot).toList();
    final mainCategory =
        _mainId == null ? null : roots.firstWhere(
            (c) => c.id == _mainId,
            orElse: () => roots.isEmpty
                ? CategoryModel(id: '', name: '', slug: '')
                : roots.first);
    final subs = mainCategory?.children ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _mainId,
          decoration: const InputDecoration(labelText: 'Ana Kategori'),
          items: roots
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: (v) {
            setState(() => _mainId = v);
            // Reset subcategory.
            ref.read(productFormProvider.notifier).update(
                  (d) => d.copyWith(categoryId: null),
                );
          },
        ),
        if (subs.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: subs.any((s) => s.id == widget.selected.categoryId)
                ? widget.selected.categoryId
                : null,
            decoration: const InputDecoration(labelText: 'Alt Kategori'),
            items: subs
                .map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) {
              ref
                  .read(productFormProvider.notifier)
                  .update((d) => d.copyWith(categoryId: v));
            },
          ),
        ],
      ],
    );
  }
}

class _StockToggle extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _StockToggle({required this.current, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'available',
          label: Text('Mevcut'),
          icon: Icon(Icons.check_circle_outline),
        ),
        ButtonSegment(
          value: 'out_of_stock',
          label: Text('Tükendi'),
          icon: Icon(Icons.remove_circle_outline),
        ),
      ],
      selected: {current},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
