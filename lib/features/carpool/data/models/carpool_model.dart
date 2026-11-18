class CarpoolModel {
  final int id;
  final int eventId;
  final String creatorName;
  final String? authorAvatarUrl;
  final String departureLocation;
  final DateTime departureTime;
  final int totalSeats;
  final int remainingSeats;
  final bool bookedByCurrentUser;
  final bool ownedByCurrentUser;
  final bool active;
  final String type;
  final String? note;

  const CarpoolModel({
    required this.id,
    required this.eventId,
    required this.creatorName,
    required this.departureLocation,
    required this.departureTime,
    required this.totalSeats,
    required this.remainingSeats,
    required this.bookedByCurrentUser,
    required this.ownedByCurrentUser,
    required this.active,
    required this.type,
    this.authorAvatarUrl,
    this.note,
  });

  factory CarpoolModel.fromJson(Map<String, dynamic> json) {
    final name =
        '${json['authorFirstName'] ?? ''} ${json['authorLastName'] ?? ''}'
            .trim();
    return CarpoolModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      eventId: (json['eventId'] as num?)?.toInt() ?? 0,
      creatorName: name.isEmpty
          ? (json['authorEmail'] as String? ?? 'Membre')
          : name,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      departureLocation: json['departureLocation'] as String? ?? '',
      departureTime:
          DateTime.tryParse(json['departureTime'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      totalSeats: (json['seatCount'] as num?)?.toInt() ?? 0,
      remainingSeats: (json['availableSeatCount'] as num?)?.toInt() ?? 0,
      bookedByCurrentUser: json['bookedByCurrentUser'] == true,
      ownedByCurrentUser: json['ownedByCurrentUser'] == true,
      active: json['active'] == true,
      type: json['type'] as String? ?? 'OFFER',
      note: json['note'] as String?,
    );
  }
}
