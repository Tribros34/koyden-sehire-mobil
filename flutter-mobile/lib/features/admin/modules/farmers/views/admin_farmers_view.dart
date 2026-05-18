import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../shared/widgets/admin_status_badge.dart';
import '../controllers/admin_farmers_controller.dart';

class AdminFarmersView extends StatefulWidget {
  const AdminFarmersView({super.key});

  @override
  State<AdminFarmersView> createState() => _AdminFarmersViewState();
}

class _AdminFarmersViewState extends State<AdminFarmersView> {
  late final AdminFarmersController _ctrl;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final repo = Get.find<AdminRepository>();
    _ctrl = Get.put(AdminFarmersController(repo));
  }

  @override
  void dispose() {
    Get.delete<AdminFarmersController>();
    _searchController.dispose();
    super.dispose();
  }

  Color _trustColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFE63946);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Üreticiler',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Sistemdeki aktif üreticilerin listesi.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'İsim, şehir veya davet kodu ara...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (v) => _ctrl.search.value = v,
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
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
            final items = _ctrl.filteredItems;
            if (items.isEmpty) {
              return const Center(child: Text('Üretici bulunamadı.'));
            }
            return RefreshIndicator(
              onRefresh: _ctrl.load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final farmer = items[i];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: _trustColor(farmer.trustScore)
                            .withOpacity(0.15),
                        child: Text(
                          farmer.trustScore.toStringAsFixed(0),
                          style: TextStyle(
                            color: _trustColor(farmer.trustScore),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              farmer.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (farmer.isFoundingFarmer)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.star,
                                  size: 16, color: Color(0xFFF59E0B)),
                            ),
                          AdminStatusBadge(status: farmer.status),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Text(
                                '${farmer.city}, ${farmer.district}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.inventory_2_outlined,
                                  size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Text(
                                '${farmer.productCount} ürün',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.people_outline,
                                  size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Text(
                                '${farmer.usedInvites}/${farmer.inviteQuota}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/admin/farmers/${farmer.id}'),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
