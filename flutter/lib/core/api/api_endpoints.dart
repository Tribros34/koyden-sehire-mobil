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
}
