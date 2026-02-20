enum UserRole {
  admin,
  bureau,
  membre,
}

class UserModel {
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String licence;
  final String club;
  final String niveau;
  final int nombrePlongees;
  final UserRole role;

  UserModel({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.licence,
    required this.club,
    required this.niveau,
    required this.nombrePlongees,
    required this.role,
  });
}
