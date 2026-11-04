import '../context/cubit/context_cubit.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/presentation/cubit/home_cubit.dart';
import 'bo_widgets.dart';

Future<bool> editBoEvent(
  BuildContext context,
  ClubApi api, {
  Json? event,
  bool training = false,
}) async {
  final categories = await api.list('/api/event-categories');
  if (!context.mounted) return false;
  final initial = <String, dynamic>{
    'published': true,
    'attendanceTrackingEnabled': false,
    'recurrenceInterval': 1,
    'recurrenceDays': <String>[],
    'category': training ? 'Entraînement' : null,
    ...?event,
  };
  if (initial['recurrenceDays'] is String)
    initial['recurrenceDays'] = (initial['recurrenceDays'] as String).split(
      ',',
    );
  initial['scope'] = 'OCCURRENCE';
  final saved = await boOpen<bool>(
    context,
    BoForm(
      title: event == null
          ? (training ? 'Créer un entraînement' : 'Créer un événement')
          : 'Modifier l’événement',
      initial: initial,
      fields: [
        const BoField('title', 'Titre', required: true),
        const BoField('location', 'Lieu'),
        const BoField('description', 'Description', kind: 'multiline'),
        if (event == null)
          BoField(
            'categoryId',
            'Catégorie du club',
            options: {
              for (final c in categories) '${c['id']}': label(c, 'name'),
            },
          ),
        const BoField('category', 'Catégorie libre (sans catégorie du club)'),
        const BoField('startDate', 'Début', kind: 'datetime', required: true),
        BoField(
          'endDate',
          'Fin',
          kind: 'datetime',
          required: event?['endDate'] != null,
        ),
        const BoField(
          'capacity',
          'Nombre de places (vide : illimité)',
          kind: 'number',
          min: 1,
        ),
        const BoField(
          'attendanceTrackingEnabled',
          'Activer le pointage des présences',
          kind: 'bool',
        ),
        const BoField('published', 'Publié', kind: 'bool'),
        if (event == null) ...[
          BoField(
            'recurrenceFrequency',
            'Répétition',
            options: choices(['WEEKLY', 'MONTHLY']),
          ),
          const BoField(
            'recurrenceInterval',
            'Intervalle de répétition',
            kind: 'number',
            min: 1,
            max: 12,
          ),
          const BoField('recurrenceUntil', 'Répéter jusqu’au', kind: 'date'),
          BoField(
            'recurrenceDays',
            'Jours de la semaine',
            kind: 'multi',
            options: choices([
              'MONDAY',
              'TUESDAY',
              'WEDNESDAY',
              'THURSDAY',
              'FRIDAY',
              'SATURDAY',
              'SUNDAY',
            ]),
          ),
        ],
        if (event?['recurrenceSeriesId'] != null)
          BoField(
            'scope',
            'Appliquer la modification à',
            required: true,
            options: choices(['OCCURRENCE', 'SERIES']),
          ),
      ],
      validate: (v) => validateBoEvent(
        event == null ? v : {...v, 'recurrenceFrequency': null},
      ),
      save: (data) async {
        final v = Map<String, dynamic>.from(data);
        final scope = v.remove('scope') ?? 'OCCURRENCE';
        v['categoryId'] = int.tryParse('${v['categoryId']}');
        if (v['capacity'] is num)
          v['capacity'] = (v['capacity'] as num).toInt();
        if (v['recurrenceInterval'] is num)
          v['recurrenceInterval'] = (v['recurrenceInterval'] as num).toInt();
        if (event != null) {
          v['capacity'] ??= 0; // PATCH uses zero to restore unlimited capacity.
          for (final key in ['description', 'location', 'category'])
            v[key] ??= '';
        }
        final keys = [
          'title',
          'description',
          'location',
          'category',
          'published',
          'startDate',
          'endDate',
          'capacity',
          'attendanceTrackingEnabled',
          if (event == null) ...[
            'categoryId',
            'recurrenceFrequency',
            'recurrenceInterval',
            'recurrenceUntil',
            'recurrenceDays',
          ],
        ];
        final payload = <String, dynamic>{for (final key in keys) key: v[key]};
        await api.request(
          '/api/events${event == null ? '' : '/${event['id']}'}',
          method: event == null ? 'POST' : 'PATCH',
          query: event == null ? null : {'scope': scope},
          data: payload,
        );
      },
    ),
  );
  if (saved == true && context.mounted)
    await context.read<HomeCubit>().loadEvents();
  return saved == true;
}

String? validateBoEvent(Json v) {
  final start = DateTime.tryParse('${v['startDate']}');
  final end = DateTime.tryParse('${v['endDate']}');
  if (start == null) return 'Choisissez une date de début.';
  if (end != null && !end.isAfter(start))
    return 'La fin doit être après le début.';
  if (v['recurrenceFrequency'] != null) {
    final until = DateTime.tryParse('${v['recurrenceUntil']}');
    if (until == null ||
        until.isBefore(DateTime(start.year, start.month, start.day)))
      return 'Choisissez une fin de répétition après le début.';
  }
  for (final key in ['capacity', 'recurrenceInterval']) {
    if (v[key] is num && v[key] != (v[key] as num).round())
      return 'Les places et intervalles doivent être des nombres entiers.';
  }
  return null;
}

class BoEvents extends StatelessWidget {
  const BoEvents({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Gestion des événements',
    load: allBoEvents,
    actions: [
      IconButton(
        tooltip: 'Catégories',
        onPressed: () => boOpen(context, const BoEventCategories()),
        icon: const Icon(Icons.category_outlined),
      ),
      IconButton(
        tooltip: 'Statistiques des présences',
        onPressed: () => boOpen(context, const BoAttendanceStats()),
        icon: const Icon(Icons.insights),
      ),
    ],
    add: (context, api, reload) async {
      if (await editBoEvent(context, api)) await reload();
    },
    tile: (context, api, e, reload) => BoCard(
      title: label(e, 'title'),
      subtitle:
          '${label(e, 'startDate').replaceAll('T', ' ')} · ${e['published'] == true ? 'Publié' : 'Brouillon'}\n${label(e, 'location')}\n${e['goingCount'] ?? 0} inscrit(s) · ${e['waitlistedCount'] ?? 0} en attente${e['capacity'] == null ? '' : ' · ${e['capacity']} places'}${e['recurrenceSeriesId'] == null ? '' : '\nÉvénement récurrent'}',
      children: [
        Wrap(
          children: [
            BoAction('Modifier', () async {
              if (await editBoEvent(context, api, event: e)) await reload();
            }),
            BoAction('Participants et présences', () async {
              await boOpen(context, BoParticipants(event: e));
              await reload();
            }),
            if (context
                    .read<ContextCubit>()
                    .state
                    .context
                    ?.currentAssociation
                    ?.modules
                    .contains('CARPOOLING') ==
                true)
              BoAction('Covoiturages', () async {
                await boOpen(
                  context,
                  BoCarpoolModeration(eventId: e['id'] as int),
                );
              }),
            BoAction('Supprimer', () async {
              String scope = 'OCCURRENCE';
              if (e['recurrenceSeriesId'] != null) {
                final picked = await showDialog<String>(
                  context: context,
                  builder: (c) => SimpleDialog(
                    title: const Text('Supprimer quelle partie ?'),
                    children: [
                      for (final entry in choices([
                        'OCCURRENCE',
                        'SERIES',
                      ]).entries)
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(c, entry.key),
                          child: Text(entry.value),
                        ),
                    ],
                  ),
                );
                if (picked == null) return;
                scope = picked;
              }
              if (context.mounted)
                await boDelete(
                  context,
                  api,
                  '/api/events/${e['id']}',
                  () async {
                    await reload();
                    if (context.mounted)
                      await context.read<HomeCubit>().loadEvents();
                  },
                  query: {'scope': scope},
                );
            }),
          ],
        ),
      ],
    ),
  );
}

class BoParticipants extends StatelessWidget {
  final Json event;
  const BoParticipants({super.key, required this.event});
  @override
  Widget build(BuildContext context) {
    final started =
        DateTime.tryParse('${event['startDate']}')?.isBefore(DateTime.now()) ??
        false;
    final canMark = event['attendanceTrackingEnabled'] == true && started;
    return BoList(
      title: 'Participants · ${label(event, 'title')}',
      load: (api) => api.list('/api/events/${event['id']}/participants'),
      tile: (context, api, p, reload) => BoCard(
        title: person(p),
        subtitle:
            '${label(p, 'email')}\n${boLabel(p['status'])} · ${boLabel(p['attendanceStatus'])}',
        children: [
          if (canMark)
            Wrap(
              children: [
                for (final s in ['PRESENT', 'ABSENT', 'UNMARKED'])
                  BoAction(boLabel(s), () async {
                    await api.request(
                      '/api/events/${event['id']}/participants/${p['userId']}/attendance',
                      method: 'PUT',
                      query: {'status': s},
                    );
                    await reload();
                  }),
              ],
            )
          else
            Text(
              event['attendanceTrackingEnabled'] != true
                  ? 'Pointage désactivé pour cet événement.'
                  : 'Pointage disponible au début de l’événement.',
            ),
        ],
      ),
    );
  }
}

class BoAttendanceStats extends StatelessWidget {
  const BoAttendanceStats({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Statistiques de présence',
    load: (api) => api.list('/api/events/attendance/stats'),
    tile: (context, api, s, reload) => BoCard(
      title: person(s),
      subtitle:
          '${s['presentCount'] ?? 0} présence(s) · ${s['absentCount'] ?? 0} absence(s)\nTaux : ${s['attendanceRate'] ?? 0} %\n${s['verifiedCount'] ?? 0} pointage(s) · ${s['declaredCount'] ?? 0} déclaration(s)',
    ),
  );
}

class BoEventCategories extends StatelessWidget {
  const BoEventCategories({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Catégories des événements',
    load: (api) => api.list('/api/event-categories'),
    add: (context, api, reload) async {
      final ok = await boOpen<bool>(
        context,
        BoForm(
          title: 'Créer une catégorie',
          fields: const [BoField('name', 'Nom', required: true)],
          help: 'Sélectionnez ensuite une image pour cette catégorie.',
          save: (v) async {
            final images = await pickBoFiles(images: true);
            if (images.isEmpty) throw StateError('Choisissez une image.');
            await api.request(
              '/api/event-categories',
              method: 'POST',
              data: FormData.fromMap({...v, 'image': images.single}),
            );
          },
        ),
      );
      if (ok == true) await reload();
    },
    tile: (context, api, c, reload) => BoCard(
      title: label(c, 'name'),
      children: [
        if (c['imageUrl'] != null)
          Image.network(
            api.imageUrl(label(c, 'imageUrl')),
            height: 100,
            errorBuilder: (_, e, s) => const Icon(Icons.image_not_supported),
          ),
        BoAction(
          'Supprimer',
          () => boDelete(
            context,
            api,
            '/api/event-categories/${c['id']}',
            reload,
          ),
        ),
      ],
    ),
  );
}

class BoCarpoolModeration extends StatelessWidget {
  final int eventId;
  const BoCarpoolModeration({super.key, required this.eventId});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Gestion des covoiturages',
    load: (api) => api.list(
      '/api/events/$eventId/carpools',
      query: {'includeInactive': true},
    ),
    tile: (context, api, c, reload) => BoCard(
      title: '${label(c, 'authorFirstName')} ${label(c, 'authorLastName')}',
      subtitle:
          '${label(c, 'departureLocation')} · ${label(c, 'departureTime')}\n${c['availableSeatCount'] ?? 0} place(s) disponible(s) · ${c['active'] == true ? 'Actif' : 'Masqué'}',
      children: [
        Wrap(
          children: [
            BoAction('Passagers', () async {
              await boOpen(
                context,
                BoList(
                  title: 'Passagers',
                  load: (a) => a.list('/api/carpools/${c['id']}/passengers'),
                  tile: (context, a, p, r) => ListTile(
                    title: Text(person(p)),
                    subtitle: Text(label(p, 'email')),
                  ),
                ),
              );
            }),
            BoAction(c['active'] == true ? 'Masquer' : 'Réactiver', () async {
              await api.request(
                '/api/carpools/${c['id']}/active',
                method: 'PATCH',
                query: {'active': c['active'] != true},
              );
              await reload();
            }),
            BoAction(
              'Supprimer',
              () => boDelete(context, api, '/api/carpools/${c['id']}', reload),
            ),
          ],
        ),
      ],
    ),
  );
}
