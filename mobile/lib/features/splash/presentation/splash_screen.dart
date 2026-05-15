import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants.dart';
import '../../../app/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final start = DateTime.now();
    await ref.read(authProvider.notifier).bootstrap();
    final elapsed = DateTime.now().difference(start);
    if (elapsed < const Duration(milliseconds: 1200)) {
      await Future.delayed(
        const Duration(milliseconds: 1200) - elapsed,
      );
    }
    if (!mounted) return;
    final auth = ref.read(authProvider);
    switch (auth.status) {
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
            Text(
              AppConstants.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: TextStyle(color: Colors.white.withOpacity(0.85)),
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
