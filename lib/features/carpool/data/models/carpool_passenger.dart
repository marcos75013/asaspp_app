class CarpoolPassenger {
  final int id;
  final String name;
  final String? avatarUrl;

  const CarpoolPassenger({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory CarpoolPassenger.fromJson(Map<String, dynamic> json) {
    final name = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    return CarpoolPassenger(
      id: (json['userId'] as num?)?.toInt() ?? 0,
      name: name.isEmpty ? 'Membre' : name,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
