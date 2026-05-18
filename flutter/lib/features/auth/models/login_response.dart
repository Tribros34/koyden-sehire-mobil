import 'user_model.dart';

class LoginResponse {
  final String accessToken;
  final UserModel user;
  const LoginResponse({required this.accessToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token']?.toString() ?? '',
        user: UserModel.fromJson(
          (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );
}
