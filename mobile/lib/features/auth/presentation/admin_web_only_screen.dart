import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class AdminWebOnlyScreen extends ConsumerWidget {
  const AdminWebOnlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.admin_panel_settings_outlined,
                  size: 96, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Yönetici Hesabı',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Admin panel web üzerinden yönetilir.\n'
                'Bu hesapla mobil uygulamaya giriş yapamazsınız.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Çıkış Yap',
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
