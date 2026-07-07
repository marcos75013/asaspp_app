class MobileUserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;

  const MobileUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
  });

  factory MobileUserModel.fromJson(Map<String, dynamic> json) {
    return MobileUserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
    );
  }
}