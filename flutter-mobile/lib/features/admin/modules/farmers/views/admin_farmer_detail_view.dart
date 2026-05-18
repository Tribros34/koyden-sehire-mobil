import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/admin_farmer_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../controllers/admin_farmer_detail_controller.dart';

class AdminFarmerDetailView extends StatefulWidget {
  final String farmerId;
  const AdminFarmerDetailView({super.key, required this.farmerId});

  @override
  State<AdminFarmerDetailView> createState() =>
      _AdminFarmerDetailViewState();
}

class _AdminFarmerDetailViewState
    extends State<AdminFarmerDetailView> {
  late final AdminFarmerDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    final repo = Get.find<AdminRepository>();
    _ctrl = Get.put(
        AdminFarmerDetailController(repo, widget.farmerId));
  }

  @override
  void dispose() {
    Get.delete<AdminFarmerDetailController>();
    super.dispose();
  }

  Color _trustColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFE63946);
  }

  void _showQuotaDialog(AdminFarmerDetail farmer) {
    final ctrl = TextEditingController(text: farmer.inviteQuota.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Davet Kotasını Düzenle'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Kota'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final q = int.tryParse(ctrl.text);
              if (q != null) {
                _ctrl.updateQuota(q);
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
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
              TextButton(onPressed: _ctrl.load, child: const Text('Tekrar Dene')),
            ],
          ),
        );
      }
      final farmer = _ctrl.farmer.value;
      if (farmer == null) return const SizedBox();

      return RefreshIndicator(
        onRefresh: _ctrl.load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoCard(farmer: farmer),
              const SizedBox(height: 12),
              _TrustCard(farmer: farmer, trustColor: _trustColor),
              const SizedBox(height: 12),
              _InviteCard(
                farmer: farmer,
                onEditQuota: () => _showQuotaDialog(farmer),
              ),
              const SizedBox(height: 16),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _ctrl.isActioning.value
                          ? null
                          : _ctrl.toggleStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: farmer.isActive
                            ? const Color(0xFFE63946)
                            : const Color(0xFF10B981),
                      ),
                      icon: Icon(farmer.isActive
                          ? Icons.block
                          : Icons.check_circle_outline),
                      label: Text(farmer.isActive
                          ? 'Hesabı Askıya Al'
                          : 'Hesabı Aktifleştir'),
                    ),
                  )),
            ],
          ),
        ),
      );
    });
  }
}

class _InfoCard extends StatelessWidget {
  final AdminFarmerDetail farmer;
  const _InfoCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Kişisel Bilgiler',
                    style: Theme.of(context).textTheme.titleMedium),
                if (farmer.isFoundingFarmer) ...[
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('Kurucu', style: TextStyle(fontSize: 11)),
                    backgroundColor: Color(0xFFFEF3C7),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ],
            ),
            const Divider(height: 16),
            _Row(label: 'Ad Soyad', value: farmer.fullName),
            _Row(label: 'Telefon', value: farmer.phone),
            _Row(label: 'Şehir', value: '${farmer.city}, ${farmer.district}'),
            _Row(
                label: 'Durum',
                value: farmer.isActive ? 'Aktif' : 'Askıda',
                valueColor: farmer.isActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE63946)),
          ],
        ),
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final AdminFarmerDetail farmer;
  final Color Function(double) trustColor;
  const _TrustCard({required this.farmer, required this.trustColor});

  @override
  Widget build(BuildContext context) {
    final color = trustColor(farmer.trustScore);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Güven Skoru', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withOpacity(0.15),
                  child: Text(
                    farmer.trustScore.toStringAsFixed(0),
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _Metric(
                          label: 'Profil Tamamlama',
                          value:
                              '%${farmer.profileCompletion.toStringAsFixed(0)}'),
                      _Metric(
                          label: 'Video Doğrulama',
                          value: farmer.hasVideoVerification ? 'Var' : 'Yok'),
                      _Metric(
                          label: 'Onaylı Ürünler',
                          value: farmer.approvedProducts.toString()),
                      _Metric(
                          label: 'Şikayetler',
                          value: farmer.complaints.toString()),
                      _Metric(
                          label: 'Davet Geçmişi',
                          value: farmer.inviteHistory.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final AdminFarmerDetail farmer;
  final VoidCallback onEditQuota;
  const _InviteCard({required this.farmer, required this.onEditQuota});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Davet Bilgileri',
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                    onPressed: onEditQuota,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Kotayı Düzenle'),
              ],
            ),
            const Divider(height: 16),
            if (farmer.inviteCode != null)
              _Row(label: 'Davet Kodu', value: farmer.inviteCode!),
            _Row(
                label: 'Kota',
                value:
                    '${farmer.usedInvites} / ${farmer.inviteQuota} kullanıldı'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
