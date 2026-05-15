import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/admin_web_only_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/providers/auth_state.dart';
import '../features/farmer_application/presentation/application_form_screen.dart';
import '../features/farmer_application/presentation/application_success_screen.dart';
import '../features/farmer_application/presentation/invite_entry_screen.dart';
import '../features/farmer_panel/dashboard/presentation/farmer_dashboard_screen.dart';
import '../features/farmer_panel/invitations/presentation/invitations_screen.dart';
import '../features/farmer_panel/products/presentation/my_products_screen.dart';
import '../features/farmer_panel/products/presentation/product_form_screen.dart';
import '../features/farmer_panel/profile/presentation/farmer_profile_screen.dart';
import '../features/otp/presentation/otp_screen.dart';
import '../features/public/farmers/presentation/farmer_profile_screen.dart';
import '../features/public/home/presentation/home_screen.dart';
import '../features/public/products/presentation/product_detail_screen.dart';
import '../features/public/products/presentation/product_list_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

const _publicRoutes = {
  '/',
  '/products',
  '/search',
  '/apply',
  '/apply/form',
  '/apply/success',
  '/login',
  '/otp',
};

bool _isPublic(String path) {
  if (_publicRoutes.contains(path)) return true;
  if (path.startsWith('/products/')) return true;
  if (path.startsWith('/farmers/')) return true;
  return false;
}

/// Notifier the router can listen to so guard logic re-runs on auth changes.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshListenable(ref);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/splash') return null;

      final auth = ref.read(authProvider);

      if (auth.status == AuthStatus.admin) {
        return loc == '/admin' ? null : '/admin';
      }

      if (auth.status == AuthStatus.farmerActive) {
        if (loc == '/login') return '/farmer/dashboard';
        return null;
      }

      // logged out / unknown → only public routes allowed
      if (loc.startsWith('/farmer') || loc == '/admin') {
        return '/login';
      }
      if (_isPublic(loc)) return null;
      return '/login';
    },
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Sayfa bulunamadı: ${state.uri.path}')),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (_, state) => ProductListScreen(
          initialCategoryId: state.uri.queryParameters['category_id'],
          initialSearch: state.uri.queryParameters['search'],
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (_, state) => ProductListScreen(
          initialSearch: state.uri.queryParameters['q'],
        ),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (_, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/farmers/:id',
        builder: (_, state) =>
            FarmerProfileScreen(farmerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminWebOnlyScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      // Application flow
      GoRoute(
        path: '/apply',
        builder: (_, state) => InviteEntryScreen(
          prefillCode: state.uri.queryParameters['invite'],
        ),
      ),
      GoRoute(
        path: '/apply/form',
        builder: (_, __) => const ApplicationFormScreen(),
      ),
      GoRoute(
        path: '/apply/success',
        builder: (_, __) => const ApplicationSuccessScreen(),
      ),
      // Farmer panel
      GoRoute(
        path: '/farmer/dashboard',
        builder: (_, __) => const FarmerDashboardScreen(),
      ),
      GoRoute(
        path: '/farmer/profile',
        builder: (_, __) => const FarmerProfileEditScreen(),
      ),
      GoRoute(
        path: '/farmer/products',
        builder: (_, __) => const MyProductsScreen(),
      ),
      GoRoute(
        path: '/farmer/products/new',
        builder: (_, __) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/farmer/products/:id/edit',
        builder: (_, state) =>
            ProductFormScreen(editingId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/farmer/invites',
        builder: (_, __) => const InvitationsScreen(),
      ),
    ],
  );
});
