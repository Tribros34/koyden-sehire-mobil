import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:koyden_sehire/app/constants.dart';
import 'package:koyden_sehire/app/theme.dart';
import 'package:koyden_sehire/core/services/auth_service.dart';
import 'package:koyden_sehire/models/auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = Get.find<AuthService>();
    final start = DateTime.now();
    await auth.bootstrap();
    final elapsed = DateTime.now().difference(start);
    if (elapsed < const Duration(milliseconds: 1200)) {
      await Future.delayed(const Duration(milliseconds: 1200) - elapsed);
    }
    if (!mounted) return;
    switch (auth.status.value) {
      case AuthStatus.farmerActive:
        context.go('/farmer/dashboard');
        break;
      case AuthStatus.admin:
        context.go('/admin');
        break;
      case AuthStatus.customerActive:
        context.go('/');
        break;
      case AuthStatus.farmerSuspended:
        context.go('/login');
        break;
      case AuthStatus.loggedOut:
      case AuthStatus.unknown:
        context.go('/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_outlined, color: Colors.white, size: 72),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
