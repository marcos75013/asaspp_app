import 'mobile_association_model.dart';
import 'mobile_user_model.dart';

class MobileContextModel {
  final MobileUserModel user;
  final List<MobileAssociationModel> associations;
  final MobileAssociationModel? activeAssociation;

  const MobileContextModel({
    required this.user,
    required this.associations,
    this.activeAssociation,
  });

  MobileAssociationModel? get currentAssociation {
    return activeAssociation ?? (associations.isEmpty ? null : associations.first);
  }

  MobileContextModel copyWith({
    MobileUserModel? user,
    List<MobileAssociationModel>? associations,
    MobileAssociationModel? activeAssociation,
  }) {
    return MobileContextModel(
      user: user ?? this.user,
      associations: associations ?? this.associations,
      activeAssociation: activeAssociation ?? this.activeAssociation,
    );
  }

  factory MobileContextModel.fromJson(Map<String, dynamic> json) {
    return MobileContextModel(
      user: MobileUserModel.fromJson(json['user'] ?? {}),
      associations: (json['associations'] as List<dynamic>? ?? [])
          .map((item) => MobileAssociationModel.fromJson(item))
          .toList(),
      activeAssociation: json['activeAssociation'] == null
          ? null
          : MobileAssociationModel.fromJson(json['activeAssociation']),
    );
  }
}