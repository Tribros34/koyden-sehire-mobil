import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_repository.dart';
import '../models/login_request.dart';
import 'auth_state.dart';

final authProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    storage: ref.watch(secureStorageProvider),
    repository: ref.watch(authRepositoryProvider),
    ref: ref,
  );
});

class AuthController extends StateNotifier<AuthState> {
  final SecureStorageService storage;
  final AuthRepository repository;
  final Ref ref;

  AuthController({
    required this.storage,
    required this.repository,
    required this.ref,
  }) : super(const AuthState()) {
    // Listen for 401 signals from the API client → log out.
    ref.listen<int>(unauthorizedSignalProvider, (prev, next) {
      if (prev != next) _handleUnauthorized();
    });
  }

  Future<void> _handleUnauthorized() async {
    await storage.clearAll();
    state = const AuthState(status: AuthStatus.loggedOut);
  }

  /// Read persisted state and decide where the splash should land.
  Future<void> bootstrap() async {
    final token = await storage.getToken();
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.loggedOut);
      return;
    }
    final role = await storage.getUserRole();
    final status = await storage.getUserStatus();
    final id = await storage.getUserId();
    final name = await storage.getDisplayName();

    if (role == 'admin') {
      state = AuthState(
        status: AuthStatus.admin,
        userId: id,
        displayName: name,
      );
    } else if (role == 'farmer' && status == 'active') {
      state = AuthState(
        status: AuthStatus.farmerActive,
        userId: id,
        displayName: name,
      );
    } else if (role == 'farmer' && status == 'suspended') {
      await storage.clearAll();
      state = const AuthState(
        status: AuthStatus.loggedOut,
        errorMessage: 'Hesabınız askıya alınmıştır',
      );
    } else {
      await storage.clearAll();
      state = const AuthState(status: AuthStatus.loggedOut);
    }
  }

  Future<void> login({required String phone, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final res = await repository.login(
        LoginRequest(phone: phone, password: password),
      );

      if (!res.user.isActive) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Hesabınız askıya alınmıştır',
        );
        return;
      }

      await storage.saveToken(res.accessToken);
      await storage.saveUserInfo(
        id: res.user.id,
        role: res.user.role,
        status: res.user.status,
        displayName: res.user.fullName,
      );

      AuthStatus next;
      if (res.user.isAdmin) {
        next = AuthStatus.admin;
      } else if (res.user.isFarmer && res.user.isActive) {
        next = AuthStatus.farmerActive;
      } else {
        next = AuthStatus.loggedOut;
      }

      state = AuthState(
        status: next,
        userId: res.user.id,
        displayName: res.user.fullName,
      );
    } on AppException catch (e) {
      String msg;
      switch (e.code) {
        case 'INVALID_CREDENTIALS':
          msg = 'Telefon numarası veya şifre hatalı';
          break;
        case 'ACCOUNT_INACTIVE':
          msg = 'Hesabınız askıya alınmıştır';
          break;
        default:
          msg = e.message;
      }
      state = state.copyWith(isSubmitting: false, errorMessage: msg);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Bir hata oluştu, tekrar deneyin',
      );
    } finally {
      if (state.isSubmitting) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  Future<void> logout() async {
    await storage.clearAll();
    state = const AuthState(status: AuthStatus.loggedOut);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
