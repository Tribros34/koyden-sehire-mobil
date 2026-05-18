import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/views/admin/widgets/admin_status_badge.dart';
import 'package:koyden_sehire/controllers/admin/admin_product_detail_controller.dart';

class AdminProductDetailView extends StatefulWidget {
  final String productId;
  const AdminProductDetailView({super.key, required this.productId});

  @override
  State<AdminProductDetailView> createState() =>
      _AdminProductDetailViewState();
}

class _AdminProductDetailViewState
    extends State<AdminProductDetailView> {
  late final AdminProductDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    final repo = Get.find<AdminRepository>();
    _ctrl = Get.put(
        AdminProductDetailController(repo, productId: widget.productId));
  }

  @override
  void dispose() {
    Get.delete<AdminProductDetailController>();
    super.dispose();
  }

  Future<void> _confirmModerate(String action) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action == 'approve' ? 'Ürünü Onayla' : 'Ürünü Reddet'),
        content: action == 'reject'
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Reddetme sebebini yazın:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonCtrl,
                    decoration:
                        const InputDecoration(hintText: 'Sebep...'),
                    maxLines: 2,
                  ),
                ],
              )
            : const Text('Bu ürünü onaylamak istiyor musunuz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: action == 'reject'
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(action == 'approve' ? 'Onayla' : 'Reddet'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await _ctrl.moderate(action,
          reason: action == 'reject' ? reasonCtrl.text : null);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                action == 'approve' ? 'Ürün onaylandı.' : 'Ürün reddedildi.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_ctrl.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_ctrl.error.value),
              TextButton(
                  onPressed: _ctrl.load, child: const Text('Tekrar Dene')),
            ],
          ),
        );
      }

      final product = _ctrl.product.value;
      if (product == null) return const SizedBox.shrink();

      return Scaffold(
        appBar: AppBar(
          title: Text(product.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin/products'),
          ),
          actions: (product.status == 'pending')
              ? [
                  if (_ctrl.isSubmitting.value)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else ...[
                    TextButton.icon(
                      onPressed: () => _confirmModerate('reject'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Reddet',
                          style: TextStyle(color: Colors.red)),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmModerate('approve'),
                      icon: const Icon(Icons.check,
                          color: Color(0xFF2D6A4F)),
                      label: const Text('Onayla',
                          style: TextStyle(color: Color(0xFF2D6A4F))),
                    ),
                  ],
                ]
              : null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imageUrls.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: product.imageUrls.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                    itemBuilder: (ctx, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrls[i],
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                            ),
                          ),
                          AdminStatusBadge(status: product.status),
                        ],
                      ),
                      const Divider(height: 20),
                      _Row('Fiyat',
                          '${product.price} ₺ / ${product.unit}'),
                      _Row('Şehir', product.city),
                      if (product.district != null)
                        _Row('İlçe', product.district!),
                      if (product.category != null)
                        _Row('Kategori', product.category!.name),
                      if (product.farmer != null) ...[
                        _Row('Üretici', product.farmer!.displayName),
                        if (product.farmer!.city != null)
                          _Row('Üretici Şehri', product.farmer!.city!),
                      ],
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Açıklama',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(product.description!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
