import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/presentation/cubit/home_cubit.dart';
import '../home/presentation/cubit/home_state.dart';
import '../home/data/models/next_event_model.dart';
import '../carpool/presentation/pages/join_carpool_screen.dart';
import '../carpool/presentation/pages/create_carpool_screen.dart';
import '../context/cubit/context_cubit.dart';
import '../../core/data/association_repository.dart';
import 'bo_widgets.dart';

class MemberEventDetails extends StatelessWidget {
  final int eventId;
  const MemberEventDetails({super.key, required this.eventId});
  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, HomeState>(
    builder: (context, state) {
      final event = state.nextEvents[eventId];
      if (event == null)
        return Scaffold(
          appBar: AppBar(title: const Text('Événement')),
          body: const Center(
            child: Text('Cet événement n’est plus disponible.'),
          ),
        );
      final e = event.raw;
      final carpool =
          context
              .read<ContextCubit>()
              .state
              .context
              ?.currentAssociation
              ?.modules
              .contains('CARPOOLING') ==
          true;
      return Scaffold(
        appBar: AppBar(title: Text(event.site)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (e['categoryImageUrl'] != null)
              FutureBuilder<ClubApi>(
                future: repositoryOf(context).api(),
                builder: (c, s) => s.hasData
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          s.data!.imageUrl(label(e, 'categoryImageUrl')),
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, s) => const SizedBox(),
                        ),
                      )
                    : const SizedBox(),
              ),
            BoCard(
              title: event.site,
              subtitle:
                  '${event.date} · ${event.time}\n${label(e, 'location')}\n${label(e, 'category')}',
              children: [
                if (event.message.isNotEmpty) Text(event.message),
                if (e['endDate'] != null)
                  Text('Fin : ${label(e, 'endDate').replaceAll('T', ' ')}'),
                if (e['recurrenceFrequency'] != null)
                  Text(
                    'Récurrence : ${boLabel(e['recurrenceFrequency'])} · intervalle ${e['recurrenceInterval'] ?? 1}\nJusqu’au ${display(e['recurrenceUntil'])}',
                  ),
              ],
            ),
            BoCard(
              title: 'Inscriptions',
              subtitle:
                  '${e['goingCount'] ?? 0} inscrit(s)${e['capacity'] == null ? ' · Places non limitées' : ' / ${e['capacity']} places'}\n${e['waitlistedCount'] ?? 0} personne(s) en liste d’attente\nMa réponse : ${boLabel(e['currentUserStatus'])}',
              children: [
                if (event.participation == ParticipationStatus.waitlisted)
                  const Text(
                    'Vous êtes sur la liste d’attente. Votre inscription dépend des places libérées.',
                  ),
                Wrap(
                  children: [
                    for (final entry in {
                      ParticipationStatus.going: 'Je viens',
                      ParticipationStatus.maybe: 'Peut-être',
                      ParticipationStatus.notGoing: 'Je ne viens pas',
                    }.entries)
                      TextButton(
                        onPressed: state.pending.contains(eventId)
                            ? null
                            : () async {
                                await context
                                    .read<HomeCubit>()
                                    .setParticipation(eventId, entry.key);
                                if (context.mounted &&
                                    context.read<HomeCubit>().state.error !=
                                        null)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.read<HomeCubit>().state.error!,
                                      ),
                                    ),
                                  );
                              },
                        child: Text(entry.value),
                      ),
                  ],
                ),
              ],
            ),
            if (carpool)
              BoCard(
                title: 'Covoiturage',
                children: [
                  Wrap(
                    children: [
                      BoAction('Offres et demandes', () async {
                        await boOpen(context, JoinCarpoolScreen(event: event));
                      }),
                      BoAction('Proposer un trajet', () async {
                        await boOpen(
                          context,
                          CreateCarpoolScreen(event: event),
                        );
                      }),
                    ],
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}
