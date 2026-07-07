enum AssociationRole {
  admin,
  member,
}

AssociationRole associationRoleFromJson(String value) {
  switch (value.toUpperCase()) {
    case 'ADMIN':
      return AssociationRole.admin;
    case 'MEMBER':
    default:
      return AssociationRole.member;
  }
}

extension AssociationRoleExtension on AssociationRole {
  String get label {
    switch (this) {
      case AssociationRole.admin:
        return 'Admin';
      case AssociationRole.member:
        return 'Membre';
    }
  }
}