import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:koyden_sehire/models/admin/admin_category_model.dart';
import 'package:koyden_sehire/services/admin_repository.dart';
import 'package:koyden_sehire/controllers/admin/admin_categories_controller.dart';

class AdminCategoriesView extends StatefulWidget {
  const AdminCategoriesView({super.key});

  @override
  State<AdminCategoriesView> createState() =>
      _AdminCategoriesViewState();
}

class _AdminCategoriesViewState
    extends State<AdminCategoriesView> {
  late final AdminCategoriesController _ctrl;

  @override
  void initState() {
    super.initState();
    final repo = Get.find<AdminRepository>();
    _ctrl = Get.put(AdminCategoriesController(repo));
  }

  @override
  void dispose() {
    Get.delete<AdminCategoriesController>();
    super.dispose();
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

      final items = _ctrl.items;
      final parents = items.where((c) => c.parentId == null).toList();

      return RefreshIndicator(
        onRefresh: _ctrl.load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategoriler',
                        style:
                            Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Platforma ait ürün kategorileri.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _CategoryTile(category: parents[i]),
                  childCount: parents.length,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CategoryTile extends StatelessWidget {
  final AdminCategory category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.category_outlined,
                  size: 18, color: Color(0xFF2D6A4F)),
            ),
            title: Text(category.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (category.children.isNotEmpty)
                  Text(
                    '${category.children.length} alt kategori',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                const SizedBox(width: 4),
                _StatusDot(active: category.active),
              ],
            ),
          ),
          if (category.children.isNotEmpty)
            ...category.children.map(
              (child) => Padding(
                padding:
                    const EdgeInsets.only(left: 32, bottom: 4, right: 12),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.subdirectory_arrow_right,
                      size: 16, color: Colors.grey),
                  title: Text(child.name,
                      style: const TextStyle(fontSize: 14)),
                  trailing: _StatusDot(active: child.active),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool active;
  const _StatusDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
