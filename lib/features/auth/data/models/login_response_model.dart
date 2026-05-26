import '../../domain/entities/auth_session.dart';

class LoginResponseModel extends AuthSession {
  const LoginResponseModel({
    required super.accessToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['token'] as String? ?? '',
    );
  }
}