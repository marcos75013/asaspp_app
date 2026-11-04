import '../../../connected/data/club_api.dart';
import '../../../connected/presentation/club_widgets.dart' show dateLabel;

enum DiveType { mer, piscine, carriere, apero, formation, stage, fosse }

enum ParticipationStatus { none, going, maybe, notGoing, waitlisted }

class NextEventModel {
  final int id;
  final String site, date, time, message;
  final DiveType diveType;
  final ParticipationStatus participation;
  final Json raw;
  const NextEventModel({
    required this.id,
    required this.site,
    required this.date,
    required this.time,
    required this.diveType,
    required this.message,
    this.participation = ParticipationStatus.none,
    this.raw = const {},
  });
  factory NextEventModel.fromJson(Json data) {
    final category = label(data, 'category').toLowerCase();
    final type = category.contains('piscine')
        ? DiveType.piscine
        : category.contains('fosse')
        ? DiveType.fosse
        : category.contains('carri')
        ? DiveType.carriere
        : category.contains('apéro') || category.contains('apero')
        ? DiveType.apero
        : category.contains('formation')
        ? DiveType.formation
        : category.contains('stage')
        ? DiveType.stage
        : DiveType.mer;
    final formatted = dateLabel(data['startDate']).split(' · ');
    return NextEventModel(
      id: data['id'] as int,
      site: label(data, 'title'),
      date: formatted.first,
      time: formatted.length > 1 ? formatted.last : '',
      diveType: type,
      message: label(data, 'description'),
      raw: data,
      participation: switch (data['currentUserStatus']) {
        'GOING' => ParticipationStatus.going,
        'MAYBE' => ParticipationStatus.maybe,
        'NOT_GOING' => ParticipationStatus.notGoing,
        'WAITLISTED' => ParticipationStatus.waitlisted,
        _ => ParticipationStatus.none,
      },
    );
  }
}
