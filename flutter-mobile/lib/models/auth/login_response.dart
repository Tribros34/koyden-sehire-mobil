import 'package:koyden_sehire/models/auth/user_model.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token']?.toString() ?? '',
        refreshToken: json['refresh_token']?.toString() ?? '',
        user: UserModel.fromJson(
          (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );
}
