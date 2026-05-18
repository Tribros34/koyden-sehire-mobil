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
      await Future.delayed(
        const Duration(milliseconds: 1200) - elapsed,
      );
    }
    if (!mounted) return;
    switch (auth.status.value) {
      case AuthStatus.farmerActive:
        context.go('/farmer/dashboard');
        break;
      case AuthStatus.admin:
        context.go('/admin');
        break;
      case AuthStatus.farmerSuspended:
      case AuthStatus.loggedOut:
      case AuthStatus.unknown:
        context.go('/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_outlined, color: Colors.white, size: 72),
            const SizedBox(height: 16),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 32),
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
