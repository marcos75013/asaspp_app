class AssociationAbout {
  final int associationId;
  final String associationName;
  final String? logoUrl;
  final AboutPresentation presentation;
  final List<OrganizationPosition> positions;
  final List<OrganizationSection> sections;
  final Map<int, OrganizationMember> members;

  const AssociationAbout({
    required this.associationId,
    required this.associationName,
    this.logoUrl,
    required this.presentation,
    required this.positions,
    this.sections = const [],
    required this.members,
  });

  factory AssociationAbout.fromJson(Map<String, dynamic> json) {
    final org = Map<String, dynamic>.from(json['organization'] as Map? ?? {});
    final members = (org['members'] as List? ?? const []).map(
      (item) =>
          OrganizationMember.fromJson(Map<String, dynamic>.from(item as Map)),
    );
    return AssociationAbout(
      associationId: (json['associationId'] as num).toInt(),
      associationName: json['associationName'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      presentation: AboutPresentation.fromJson(
        Map<String, dynamic>.from(json['presentation'] as Map? ?? {}),
      ),
      positions: (org['positions'] as List? ?? const [])
          .map(
            (item) => OrganizationPosition.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      sections: (org['sections'] as List? ?? const [])
          .map(
            (item) => OrganizationSection.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      members: {for (final member in members) member.id: member},
    );
  }

  List<OrganizationSection> get displaySections => sections.isEmpty
      ? [
          if (positions.isNotEmpty)
            OrganizationSection('Organigramme', positions),
        ]
      : sections.where((section) => section.positions.isNotEmpty).toList();

  List<OrganizationPosition> get orderedPositions => orderPositions(positions);
}

class OrganizationSection {
  final String title;
  final List<OrganizationPosition> positions;

  const OrganizationSection(this.title, this.positions);

  factory OrganizationSection.fromJson(Map<String, dynamic> json) =>
      OrganizationSection(
        json['title'] as String? ??
            (json['id'] == 'BUREAU' ? 'Bureau' : 'Encadrement'),
        (json['positions'] as List? ?? const [])
            .map(
              (item) => OrganizationPosition.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );

  List<OrganizationPosition> get orderedPositions => orderPositions(positions);
}

List<OrganizationPosition> orderPositions(
  List<OrganizationPosition> positions,
) {
  final result = <OrganizationPosition>[];
  final visited = <String>{};
  void visit(String? parent, int depth) {
    for (final position in positions.where((item) => item.parentId == parent)) {
      if (!visited.add(position.id)) continue;
      result.add(position.withDepth(depth));
      visit(position.id, depth + 1);
    }
  }

  visit(null, 0);
  for (final position in positions) {
    if (visited.add(position.id)) result.add(position);
  }
  return result;
}

class AboutPresentation {
  final String title;
  final String introduction;
  final bool configured;
  final List<AboutValue> values;
  final List<String> activities;
  const AboutPresentation({
    required this.title,
    required this.introduction,
    required this.configured,
    required this.values,
    required this.activities,
  });
  factory AboutPresentation.fromJson(Map<String, dynamic> json) =>
      AboutPresentation(
        title: json['title'] as String? ?? 'Qui sommes-nous',
        introduction: json['introduction'] as String? ?? '',
        configured: json['configured'] as bool? ?? false,
        values: (json['values'] as List? ?? const [])
            .map(
              (item) =>
                  AboutValue.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList(),
        activities: (json['activities'] as List? ?? const []).cast<String>(),
      );
}

class AboutValue {
  final String title;
  final String text;
  final String icon;
  const AboutValue({
    required this.title,
    required this.text,
    required this.icon,
  });
  factory AboutValue.fromJson(Map<String, dynamic> json) => AboutValue(
    title: json['title'] as String? ?? '',
    text: json['text'] as String? ?? '',
    icon: json['icon'] as String? ?? 'NONE',
  );
}

class OrganizationMember {
  final int id;
  final String name;
  final String? avatarUrl;
  const OrganizationMember({
    required this.id,
    required this.name,
    this.avatarUrl,
  });
  factory OrganizationMember.fromJson(Map<String, dynamic> json) =>
      OrganizationMember(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class OrganizationPosition {
  final String id;
  final String title;
  final int? membershipId;
  final String? parentId;
  final int depth;
  const OrganizationPosition({
    required this.id,
    required this.title,
    this.membershipId,
    this.parentId,
    this.depth = 0,
  });
  factory OrganizationPosition.fromJson(Map<String, dynamic> json) =>
      OrganizationPosition(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        membershipId: (json['membershipId'] as num?)?.toInt(),
        parentId: json['parentId'] as String?,
      );
  OrganizationPosition withDepth(int value) => OrganizationPosition(
    id: id,
    title: title,
    membershipId: membershipId,
    parentId: parentId,
    depth: value,
  );
}
