

class MobileLoginRequest {
  final String email;
  final String password;

  const MobileLoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}