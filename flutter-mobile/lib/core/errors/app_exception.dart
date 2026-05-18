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
  const NetworkException({String? message})
      : super(
          message: message ?? 'İnternet bağlantısı yok',
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
