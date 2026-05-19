import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:koyden_sehire/app/constants.dart';
import 'package:koyden_sehire/app/theme.dart';
import 'package:koyden_sehire/core/services/auth_service.dart';
import 'package:koyden_sehire/shared/widgets/app_button.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final name = auth.displayName.value ?? '';
              return Center(
                child: Text(
                  name.isNotEmpty ? name : 'Müşteri',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Müşteri Hesabı',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primaryFixed),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppConstants.platformInfoText,
                      style: TextStyle(color: AppColors.primary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Çıkış Yap',
              variant: AppButtonVariant.secondary,
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
