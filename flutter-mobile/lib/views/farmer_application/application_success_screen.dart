import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:koyden_sehire/app/theme.dart';
import 'package:koyden_sehire/shared/widgets/app_button.dart';
import 'package:koyden_sehire/controllers/application_form_controller.dart';

class ApplicationSuccessScreen extends StatelessWidget {
  const ApplicationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 96,
                  color: AppColors.success,
                ),
                const SizedBox(height: 24),
                Text(
                  'Başvurunuz Alındı!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Başvurunuz alındı. Bilgileriniz ekibimiz tarafından incelenecek. '
                  'Onaylandıktan sonra üretici panelinize giriş yaparak ürünlerinizi '
                  'ekleyebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.schedule, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Değerlendirme genellikle 1-3 iş günü içinde tamamlanır.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Ana Sayfaya Dön',
                  onPressed: () {
                    Get.find<ApplicationFormController>().reset();
                    context.go('/');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
