import 'package:get/get.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/models/login_request.dart';
import '../../features/auth/providers/auth_state.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';

/// Global authentication state, persisted via [SecureStorageService].
///
/// Replaces the previous `authProvider` (Riverpod StateNotifier).
class AuthService extends GetxService {
  final SecureStorageService _storage;
  AuthService(this._storage);

  final Rx<AuthStatus> status = AuthStatus.unknown.obs;
  final RxnString userId = RxnString();
  final RxnString displayName = RxnString();
  final RxnString errorMessage = RxnString();
  final RxBool isSubmitting = false.obs;

  AuthRepository get _repo => Get.find<AuthRepository>();

  /// Called by the API client when a 401 is received.
  Future<void> handleUnauthorized() async {
    await _storage.clearAll();
    _resetTo(AuthStatus.loggedOut);
  }

  void _resetTo(AuthStatus s, {String? id, String? name, String? error}) {
    status.value = s;
    userId.value = id;
    displayName.value = name;
    errorMessage.value = error;
    isSubmitting.value = false;
  }

  /// Read persisted state and decide where the splash should land.
  Future<void> bootstrap() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      _resetTo(AuthStatus.loggedOut);
      return;
    }
    final role = await _storage.getUserRole();
    final st = await _storage.getUserStatus();
    final id = await _storage.getUserId();
    final name = await _storage.getDisplayName();

    if (role == 'admin') {
      _resetTo(AuthStatus.admin, id: id, name: name);
    } else if (role == 'farmer' && st == 'active') {
      _resetTo(AuthStatus.farmerActive, id: id, name: name);
    } else if (role == 'farmer' && st == 'suspended') {
      await _storage.clearAll();
      _resetTo(
        AuthStatus.loggedOut,
        error: 'Hesabınız askıya alınmıştır',
      );
    } else {
      await _storage.clearAll();
      _resetTo(AuthStatus.loggedOut);
    }
  }

  Future<void> login({required String phone, required String password}) async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final res = await _repo.login(
        LoginRequest(phone: phone, password: password),
      );

      if (!res.user.isActive) {
        errorMessage.value = 'Hesabınız askıya alınmıştır';
        return;
      }

      await _storage.saveToken(res.accessToken);
      await _storage.saveUserInfo(
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

      userId.value = res.user.id;
      displayName.value = res.user.fullName;
      status.value = next;
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
      errorMessage.value = msg;
    } catch (_) {
      errorMessage.value = 'Bir hata oluştu, tekrar deneyin';
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    _resetTo(AuthStatus.loggedOut);
  }

  void clearError() {
    errorMessage.value = null;
  }
}
