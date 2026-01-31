enum DiveType {
  mer,
  piscine,
  carriere,
  apero,
  formation,
  stage,
  fosse,
}

enum ParticipationStatus {
  none,
  going,
  maybe,
  notGoing,
}

class NextEventModel {
  final String site;
  final String date;
  final String time;
  final DiveType diveType;
  final String message;
  final ParticipationStatus participation;

  const NextEventModel({
    required this.site,
    required this.date,
    required this.time,
    required this.diveType,
    required this.message,
    this.participation = ParticipationStatus.none,
  });

  NextEventModel copyWith({
    ParticipationStatus? participation,
  }) {
    return NextEventModel(
      site: site,
      date: date,
      time: time,
      diveType: diveType,
      message: message,
      participation: participation ?? this.participation,
    );
  }
}
