class CarpoolModel {
  final String id;
  final bool booked, owned;
  final String departure;
  final String eventName;
  final String creatorName;
  final int totalSeats;
  final int remainingSeats;

  const CarpoolModel({
    required this.id,
    this.booked = false,
    this.owned = false,
    this.departure = '',
    required this.eventName,
    required this.creatorName,
    required this.totalSeats,
    required this.remainingSeats,
  });
}
