class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );
  static const String appName = 'Köyden Şehre';
  static const String appTagline = 'Yerel üreticilerden taze ürünler';
  static const String appVersion = '1.0.0';

  static const Duration apiConnectTimeout = Duration(seconds: 30);
  static const Duration apiReceiveTimeout = Duration(seconds: 30);

  static const int productsPageSize = 20;
  static const int otpResendCooldownSeconds = 60;
  static const int otpLength = 6;

  static const int maxProductImages = 5;
  static const int maxProductImageBytes = 5 * 1024 * 1024;
  static const int maxProfileImageBytes = 2 * 1024 * 1024;
  static const int maxApplicationVideoBytes = 50 * 1024 * 1024;

  static const String platformInfoText =
      'Köyden Şehre, üreticilerle alıcıları doğrudan buluşturan komisyonsuz '
      'bir platformdur. Platform üzerinden ödeme, sipariş, kargo veya '
      'uygulama içi mesajlaşma yapılmaz.';
}
