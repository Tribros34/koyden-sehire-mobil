import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/modules/applications/views/admin_application_detail_view.dart';
import '../features/admin/modules/applications/views/admin_applications_view.dart';
import '../features/admin/modules/categories/views/admin_categories_view.dart';
import '../features/admin/modules/dashboard/views/admin_dashboard_view.dart';
import '../features/admin/modules/products/views/admin_product_detail_view.dart';
import '../features/admin/modules/products/views/admin_products_view.dart';
import '../features/admin/shared/widgets/admin_shell.dart';
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
        if (loc.startsWith('/admin')) return null;
        return '/admin/dashboard';
      }

      if (auth.status == AuthStatus.farmerActive) {
        if (loc == '/login') return '/farmer/dashboard';
        return null;
      }

      // logged out / unknown → only public routes allowed
      if (loc.startsWith('/farmer') || loc.startsWith('/admin')) {
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
        redirect: (_, __) => '/admin/dashboard',
      ),
      // Admin panel (ShellRoute — ortak Drawer navigasyonu)
      ShellRoute(
        builder: (ctx, state, child) => AdminShell(
          currentLocation: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (_, __) => const AdminDashboardView(),
          ),
          GoRoute(
            path: '/admin/applications',
            builder: (_, __) => const AdminApplicationsView(),
          ),
          GoRoute(
            path: '/admin/applications/:id',
            builder: (_, state) => AdminApplicationDetailView(
              appId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/admin/products',
            builder: (_, __) => const AdminProductsView(),
          ),
          GoRoute(
            path: '/admin/products/:id',
            builder: (_, state) => AdminProductDetailView(
              productId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/admin/categories',
            builder: (_, __) => const AdminCategoriesView(),
          ),
        ],
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
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryDark = Color(0xFF1B4332);
  static const Color secondary = Color(0xFFF4A261);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE63946);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color disabled = Color(0xFFD1D5DB);
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
  );

  const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 48),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
  );
}
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants.dart';
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import '../storage/secure_storage_service.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (_) => SecureStorageService(),
);

/// Increments each time the API receives a 401. AuthController listens to
/// this to trigger logout without the interceptor needing a Ref.
final unauthorizedSignalProvider = StateProvider<int>((_) => 0);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref.watch(secureStorageProvider),
    onUnauthorized: () =>
        ref.read(unauthorizedSignalProvider.notifier).update((s) => s + 1),
  );
});

class ApiClient {
  final SecureStorageService _storage;
  late final Dio _dio;

  ApiClient(this._storage, {required void Function() onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiConnectTimeout,
        receiveTimeout: AppConstants.apiReceiveTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_storage, onUnauthorized));
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic) parse,
  }) =>
      _request('GET', path, query: query, parse: parse);

  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) parse,
  }) =>
      _request('POST', path, data: data, parse: parse);

  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) parse,
  }) =>
      _request('PUT', path, data: data, parse: parse);

  Future<T> patch<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) parse,
  }) =>
      _request('PATCH', path, data: data, parse: parse);

  Future<T> delete<T>(
    String path, {
    required T Function(dynamic) parse,
  }) =>
      _request('DELETE', path, parse: parse);

  Future<T> _request<T>(
    String method,
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    required T Function(dynamic) parse,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        queryParameters: query,
        data: data,
        options: Options(method: method),
      );
      return parse(response.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Beklenmeyen bir hata oluştu: $e');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final void Function() _onUnauthorized;

  _AuthInterceptor(this._storage, this._onUnauthorized);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.clearAll();
      _onUnauthorized();
    }
    handler.next(err);
