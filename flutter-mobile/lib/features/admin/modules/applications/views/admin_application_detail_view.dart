import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/admin_application_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../shared/widgets/admin_risk_badge.dart';
import '../../../shared/widgets/admin_status_badge.dart';
import '../controllers/admin_application_detail_controller.dart';
import '../../../../../core/utils/date_formatter.dart' show AppFormatters;

class AdminApplicationDetailView extends StatefulWidget {
  final String appId;
  const AdminApplicationDetailView({super.key, required this.appId});

  @override
  State<AdminApplicationDetailView> createState() =>
      _AdminApplicationDetailViewState();
}

class _AdminApplicationDetailViewState
    extends State<AdminApplicationDetailView> {
  late final AdminApplicationDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    final repo = Get.find<AdminRepository>();
    _ctrl = Get.put(
        AdminApplicationDetailController(repo, appId: widget.appId));
  }

  @override
  void dispose() {
    Get.delete<AdminApplicationDetailController>();
    super.dispose();
  }

  Future<void> _confirmReject() async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Başvuruyu Reddet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Lütfen reddetme sebebini yazın. Bu bilgi SMS ile üreticiye iletilecektir.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                  hintText: 'Reddetme sebebi...'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok =
          await _ctrl.review('reject', reason: reasonCtrl.text);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Başvuru reddedildi.')));
      }
    }
  }

  Future<void> _confirmApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Başvuruyu Onayla'),
        content: const Text('Bu başvuruyu onaylamak istiyor musunuz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await _ctrl.review('approve');
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Başvuru onaylandı.')));
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

      final app = _ctrl.application.value;
      if (app == null) return const SizedBox.shrink();

      return Scaffold(
        appBar: AppBar(
          title: Text(app.fullName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin/applications'),
          ),
          actions: app.status == 'pending'
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
                      onPressed: _confirmReject,
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Reddet',
                          style: TextStyle(color: Colors.red)),
                    ),
                    TextButton.icon(
                      onPressed: _confirmApprove,
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
              _InfoCard(app: app),
              const SizedBox(height: 16),
              _RiskCard(app: app),
              if (app.adminNotes != null) ...[
                const SizedBox(height: 16),
                _AdminNotesCard(notes: app.adminNotes!),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _InfoCard extends StatelessWidget {
  final AdminApplication app;
  const _InfoCard({required this.app});

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
                Text('Üretici Bilgileri',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                AdminStatusBadge(status: app.status),
              ],
            ),
            const Divider(height: 20),
            _Field('Ad Soyad', app.fullName),
            _Field('İşletme Adı', app.businessName),
            _Field('Telefon', app.phone),
            _Field(
                'Lokasyon',
                '${app.city}, ${app.district}'
                    '${app.village != null ? ' - ${app.village}' : ''}'),
            _Field('Başvuru Tarihi', AppFormatters.date(app.createdAt)),
            if (app.profileDescription != null)
              _Field('Hakkında', app.profileDescription!),
            if (app.productExamples != null)
              _Field('Ürün Örnekleri', app.productExamples!),
          ],
        ),
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final AdminApplication app;
  const _RiskCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Analizi',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 20),
            if (app.riskLevel != null)
              _RiskRow('Genel Risk', AdminRiskBadge(level: app.riskLevel!)),
            if (app.inviteCode != null)
              _StrRow('Davet Kodu',
                  '${app.inviteCode}${app.inviteTrust != null ? ' (${app.inviteTrust})' : ''}'),
            _StrRow('Video Durumu', app.videoUrl != null ? 'Yüklendi' : 'Eksik'),
          ],
        ),
      ),
    );
  }
}

class _AdminNotesCard extends StatelessWidget {
  final String notes;
  const _AdminNotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Notları',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 20),
            Text(notes),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  final String label;
  final Widget badge;
  const _RiskRow(this.label, this.badge);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        badge,
      ]),
    );
  }
}

class _StrRow extends StatelessWidget {
  final String label;
  final String value;
  const _StrRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
