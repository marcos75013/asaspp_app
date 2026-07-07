import 'association_role.dart';

class MobileAssociationModel {
  final int associationId;
  final String associationName;
  final String? logoUrl;
  final AssociationRole role;
  final List<String> modules;
  final String? type;

  const MobileAssociationModel({
    required this.associationId,
    required this.associationName,
    this.logoUrl,
    required this.role,
    required this.modules,
    this.type,
  });

  factory MobileAssociationModel.fromJson(Map<String, dynamic> json) {
    final roles = List<String>.from(json['roles'] ?? []);

    return MobileAssociationModel(
      associationId: json['associationId'] ?? json['id'] ?? 0,
      associationName: json['associationName'] ?? json['name'] ?? '',
      logoUrl: json['logoUrl'],
      role: associationRoleFromJson(
        json['role'] ?? (roles.isNotEmpty ? roles.first : 'MEMBER'),
      ),
      modules: List<String>.from(json['modules'] ?? []),
      type: json['type'],
    );
  }
}