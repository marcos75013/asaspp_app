class MobileLoginResponse {
  final String token;
  final String platformRole;
  final List<MobileLoginAssociation> associations;

  const MobileLoginResponse({
    required this.token,
    required this.platformRole,
    required this.associations,
  });

  factory MobileLoginResponse.fromJson(Map<String, dynamic> json) {
    return MobileLoginResponse(
      token: json['token'] ?? '',
      platformRole: json['platformRole'] ?? 'NONE',
      associations: (json['associations'] as List<dynamic>? ?? [])
          .map((item) => MobileLoginAssociation.fromJson(item))
          .toList(),
    );
  }
}

class MobileLoginAssociation {
  final int associationId;
  final String associationName;
  final String role;

  const MobileLoginAssociation({
    required this.associationId,
    required this.associationName,
    required this.role,
  });

  factory MobileLoginAssociation.fromJson(Map<String, dynamic> json) {
    return MobileLoginAssociation(
      associationId: json['associationId'] ?? 0,
      associationName: json['associationName'] ?? '',
      role: json['role'] ?? 'MEMBER',
    );
  }
}