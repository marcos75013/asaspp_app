class CarpoolModel {
  final String id;
  final Map<String, dynamic> raw;
  final bool request;
  final bool booked, owned;
  final String departure;
  final String eventName;
  final String creatorName;
  final int totalSeats;
  final int remainingSeats;

  const CarpoolModel({
    required this.id,
    this.raw = const {},
    this.request = false,
    this.booked = false,
    this.owned = false,
    this.departure = '',
    required this.eventName,
    required this.creatorName,
    required this.totalSeats,
    required this.remainingSeats,
  });
}
