class CarpoolModel {
  final String id;
  final String eventName;
  final String creatorName;
  final int totalSeats;
  final int remainingSeats;

  const CarpoolModel({
    required this.id,
    required this.eventName,
    required this.creatorName,
    required this.totalSeats,
    required this.remainingSeats,
  });
}
