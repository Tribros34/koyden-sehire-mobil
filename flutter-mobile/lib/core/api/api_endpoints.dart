class ApiEndpoints {
  // Public
  static const String health = '/health';
  static const String categories = '/categories';
  static const String products = '/products';
  static const String inviteValidate = '/invites/validate';

  static String productById(String id) => '/products/$id';
  static String farmerById(String id) => '/farmers/$id';
  static String farmerProducts(String farmerId) => '/farmers/$farmerId/products';

  // Auth
  static const String login = '/auth/login';

  // OTP
  static const String otpSend = '/otp/send';
  static const String otpVerify = '/otp/verify';

  // Farmer application
  static const String farmerApplications = '/farmer-applications';
  static const String applicationVideoPresignedUrl =
      '/uploads/application-video/presigned-url';

  // Farmer panel
  static const String farmerProfile = '/farmer/profile';
  static const String farmerProducts2 = '/farmer/products';
  static const String farmerInvites = '/farmer/invites';
  static const String uploadProductImage = '/farmer/uploads/product-image';
  static const String uploadProfileImage = '/farmer/uploads/profile-image';

  static String farmerProduct(String id) => '/farmer/products/$id';
  static String farmerProductStatus(String id) =>
      '/farmer/products/$id/status';

  // Admin
  static const String adminApplications = '/admin/applications';
  static String adminApplication(String id) => '/admin/applications/$id';
  static String adminApplicationAction(String id, String action) =>
      '/admin/applications/$id/$action';
  static const String adminProducts = '/admin/products';
  static String adminProduct(String id) => '/admin/products/$id';
  static String adminProductAction(String id, String action) =>
      '/admin/products/$id/$action';
  static const String adminCategories = '/categories';
}
class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const AppException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'AppException($code, $statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException()
      : super(
          message: 'İnternet bağlantısı yok',
          code: 'NETWORK',
        );
}

class ServerException extends AppException {
  const ServerException({super.message = 'Sunucu hatası. Lütfen tekrar deneyin.'})
      : super(code: 'SERVER', statusCode: 500);
}

class AuthException extends AppException {
  const AuthException({
    super.message = 'Giriş yapmanız gerekiyor',
    super.code = 'UNAUTHORIZED',
    super.statusCode = 401,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Bu işlem için yetkiniz yok',
  }) : super(code: 'FORBIDDEN', statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Bulunamadı'})
      : super(code: 'NOT_FOUND', statusCode: 404);
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  }) : super(statusCode: 400);
}

class RateLimitException extends AppException {
  final int? retryAfterSeconds;
  const RateLimitException({
    super.message = 'Çok fazla istek. Lütfen bekleyin.',
    this.retryAfterSeconds,
  }) : super(code: 'RATE_LIMIT', statusCode: 429);
}
import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Maps Dio errors and the backend response envelope into [AppException].
/// Backend error shape: `{success:false, error:{code, message}}`.
AppException mapDioError(Object error) {
  if (error is AppException) return error;
  if (error is! DioException) {
    return AppException(message: 'Beklenmeyen bir hata oluştu');
  }

  final type = error.type;
  if (type == DioExceptionType.connectionError ||
      type == DioExceptionType.connectionTimeout ||
      type == DioExceptionType.receiveTimeout ||
      type == DioExceptionType.sendTimeout) {
    return const NetworkException();
  }

  final response = error.response;
  final status = response?.statusCode;
  final data = response?.data;

  String? backendCode;
  String? backendMessage;
  if (data is Map && data['error'] is Map) {
    final err = data['error'] as Map;
    backendCode = err['code']?.toString();
    backendMessage = err['message']?.toString();
  }

  switch (status) {
    case 400:
      return ValidationException(
        message: backendMessage ?? 'Geçersiz istek',
        code: backendCode,
      );
    case 401:
      return AuthException(
        message: backendMessage ?? 'Giriş yapmanız gerekiyor',
        code: backendCode ?? 'UNAUTHORIZED',
      );
    case 403:
      return ForbiddenException(
        message: backendMessage ?? 'Bu işlem için yetkiniz yok',
      );
    case 404:
      return NotFoundException(message: backendMessage ?? 'Bulunamadı');
    case 409:
      return ValidationException(
        message: backendMessage ?? 'Çakışma oluştu',
        code: backendCode ?? 'CONFLICT',
      );
    case 429:
      final retryAfter = response?.headers.value('retry-after');
      return RateLimitException(
        message: backendMessage ?? 'Çok fazla istek. Lütfen bekleyin.',
        retryAfterSeconds: int.tryParse(retryAfter ?? ''),
      );
    case 500:
    case 502:
    case 503:
      return ServerException(
        message: backendMessage ?? 'Sunucu hatası. Lütfen tekrar deneyin.',
      );
  }

  return AppException(
    message: backendMessage ?? 'Bir hata oluştu, tekrar deneyin',
    code: backendCode,
    statusCode: status,
  );
}
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final c = Connectivity();
  return c.onConnectivityChanged.map(_isOnline).asBroadcastStream();
});

bool _isOnline(List<ConnectivityResult> results) {
  return results.any((r) => r != ConnectivityResult.none);
}

Future<bool> checkOnlineNow() async {
  final results = await Connectivity().checkConnectivity();
  return _isOnline(results);
}
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _kAccessToken = 'access_token';
  static const _kUserId = 'user_id';
  static const _kUserRole = 'user_role';
  static const _kUserStatus = 'user_status';
  static const _kDisplayName = 'display_name';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  Future<void> saveToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<String?> getToken() => _storage.read(key: _kAccessToken);

  Future<void> saveUserInfo({
    required String id,
    required String role,
    required String status,
    String? displayName,
  }) async {
    await Future.wait([
      _storage.write(key: _kUserId, value: id),
      _storage.write(key: _kUserRole, value: role),
      _storage.write(key: _kUserStatus, value: status),
      if (displayName != null)
        _storage.write(key: _kDisplayName, value: displayName),
    ]);
  }

  Future<String?> getUserId() => _storage.read(key: _kUserId);
  Future<String?> getUserRole() => _storage.read(key: _kUserRole);
  Future<String?> getUserStatus() => _storage.read(key: _kUserStatus);
  Future<String?> getDisplayName() => _storage.read(key: _kDisplayName);

  Future<void> clearAll() => _storage.deleteAll();
}
import 'package:intl/intl.dart';

class AppFormatters {
  static final _currency = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final _date = DateFormat('d MMMM y', 'tr_TR');

  static String currency(num price) => _currency.format(price);
  static String price(num price, String unit) => '${currency(price)} / $unit';

  static String date(DateTime d) => _date.format(d.toLocal());

  static String? maybeDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final parsed = DateTime.tryParse(iso);
    return parsed == null ? null : date(parsed);
