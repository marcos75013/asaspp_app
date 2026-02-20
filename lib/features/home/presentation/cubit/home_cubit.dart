import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/next_event_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit()
      : super(
    HomeState(
      nextEvents: {
        DiveType.fosse: const NextEventModel(
          site: 'Carrière de Beaumont',
          date: 'Samedi 15 février',
          time: '08h30',
          diveType: DiveType.fosse,
          message:
          'N’oubliez pas de vérifier votre matériel avant la sortie.',
        ),

        DiveType.mer: const NextEventModel(
          site: 'Étretat',
          date: 'Dimanche 23 mars',
          time: '09h00',
          diveType: DiveType.mer,
          message: 'Sortie mer – niveau 2 minimum.',
        ),

        DiveType.apero: const NextEventModel(
          site: 'Local du club',
          date: 'Vendredi 28 mars',
          time: '19h30',
          diveType: DiveType.apero,
          message: 'Apéro convivial ouvert à tous 🍻',
        ),

        DiveType.formation: const NextEventModel(
          site: 'Piscine municipale',
          date: 'Mercredi 2 avril',
          time: '20h00',
          diveType: DiveType.formation,
          message: 'Formation N1 – séance technique.',
        ),
      },
    ),
  );

  void setParticipation(DiveType type, ParticipationStatus status) {
    final event = state.nextEvents[type];
    if (event == null) return;

    emit(
      state.copyWith(
        nextEvents: {
          ...state.nextEvents,
          type: event.copyWith(participation: status),
        },
      ),
    );
  }
}
