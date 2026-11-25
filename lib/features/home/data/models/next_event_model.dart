enum DiveType { mer, piscine, carriere, apero, formation, stage, fosse, autre }

enum ParticipationStatus { none, going, maybe, notGoing, waitlisted }

class NextEventModel {
  final int id;
  final String title;
  final String site;
  final String category;
  final String? categoryImageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final int goingCount;
  final DiveType diveType;
  final String message;
  final ParticipationStatus participation;

  const NextEventModel({
    required this.id,
    required this.title,
    required this.site,
    this.category = '',
    this.categoryImageUrl,
    required this.startDate,
    this.endDate,
    this.goingCount = 0,
    required this.diveType,
    required this.message,
    this.participation = ParticipationStatus.none,
  });

  String get date {
    const weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${weekdays[startDate.weekday - 1]} '
        '${startDate.day} ${months[startDate.month - 1]}';
  }

  String get time {
    final hour = startDate.hour.toString().padLeft(2, '0');
    final minute = startDate.minute.toString().padLeft(2, '0');
    return '${hour}h$minute';
  }

  NextEventModel copyWith({ParticipationStatus? participation}) {
    return NextEventModel(
      id: id,
      title: title,
      site: site,
      category: category,
      categoryImageUrl: categoryImageUrl,
      startDate: startDate,
      endDate: endDate,
      goingCount: goingCount,
      diveType: diveType,
      message: message,
      participation: participation ?? this.participation,
    );
  }

  factory NextEventModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    final category = json['category'] as String? ?? '';
    final location = json['location'] as String? ?? '';

    return NextEventModel(
      id: json['id'] as int? ?? 0,
      title: title,
      site: location,
      category: category,
      categoryImageUrl: json['categoryImageUrl'] as String?,
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
      goingCount: (json['goingCount'] as num?)?.toInt() ?? 0,
      diveType: _diveTypeFrom(category),
      message: json['description'] as String? ?? '',
      participation: _participationFrom(json['currentUserStatus'] as String?),
    );
  }
}

DiveType _diveTypeFrom(String value) {
  final normalized = value.toLowerCase();

  if (normalized.contains('fosse')) return DiveType.fosse;
  if (normalized.contains('piscine')) return DiveType.piscine;
  if (normalized.contains('carrière') || normalized.contains('carriere')) {
    return DiveType.carriere;
  }
  if (normalized.contains('apéro') || normalized.contains('apero')) {
    return DiveType.apero;
  }
  if (normalized.contains('formation')) return DiveType.formation;
  if (normalized.contains('stage')) return DiveType.stage;

  if (normalized.contains('mer')) return DiveType.mer;
  return DiveType.autre;
}

ParticipationStatus _participationFrom(String? value) {
  return switch (value) {
    'GOING' => ParticipationStatus.going,
    'WAITLISTED' => ParticipationStatus.waitlisted,
    'MAYBE' => ParticipationStatus.maybe,
    'NOT_GOING' => ParticipationStatus.notGoing,
    _ => ParticipationStatus.none,
  };
}

String participationStatusToJson(ParticipationStatus status) {
  return switch (status) {
    ParticipationStatus.going => 'GOING',
    ParticipationStatus.maybe => 'MAYBE',
    ParticipationStatus.notGoing => 'NOT_GOING',
    ParticipationStatus.waitlisted => throw ArgumentError(
      'Waitlist status is set by the server',
    ),
    ParticipationStatus.none => throw ArgumentError(
      'A participation status is required',
    ),
  };
}
