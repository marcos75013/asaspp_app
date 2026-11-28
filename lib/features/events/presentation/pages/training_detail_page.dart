import 'package:flutter/material.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/pulse_theme.dart';
import '../../../../core/widgets/member_avatar.dart';
import '../../../home/data/models/next_event_model.dart';
import 'event_discussion_page.dart';

class TrainingDetailPage extends StatefulWidget {
  final NextEventModel training;
  final ApiClient apiClient;
  final bool isEvent;
  const TrainingDetailPage({
    super.key,
    required this.training,
    required this.apiClient,
    this.isEvent = false,
  });
  @override
  State<TrainingDetailPage> createState() => _TrainingDetailPageState();
}

class _TrainingDetailPageState extends State<TrainingDetailPage> {
  List<Map<String, dynamic>>? _participants;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _participants = null;
      _error = null;
    });
    try {
      final result = await widget.apiClient.dio.get<List<dynamic>>(
        '/api/mobile/${widget.isEvent ? 'events' : 'trainings'}/${widget.training.id}/participants',
      );
      if (mounted) {
        setState(
          () => _participants = (result.data ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de charger les participants.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.training;
    final participants = _participants;
    final theme = PulseTheme.build(Theme.of(context).brightness);
    final colors = theme.colorScheme;
    const groups = {
      'GOING': 'Présents',
      'NOT_GOING': 'Absents',
      'MAYBE': 'Peut-être',
      'WAITLISTED': 'Liste d’attente',
      null: 'Sans réponse',
    };
    final byStatus = <String?, List<Map<String, dynamic>>>{};
    for (final participant in participants ?? <Map<String, dynamic>>[]) {
      final status = participant['status'];
      final key = groups.containsKey(status) ? status as String? : null;
      (byStatus[key] ??= []).add(participant);
    }
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEvent ? 'Événement' : 'Entraînement'),
          actions: [
            IconButton(
              tooltip: 'Discussion',
              icon: const Icon(Icons.forum_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EventDiscussionPage(
                    eventId: e.id,
                    title: e.title,
                    apiClient: widget.apiClient,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _OccurrenceBanner(event: e),
            if (e.site.trim().isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on_outlined),
                title: Text(e.site),
              ),
            if (e.endDate case final end?)
              Text(
                'Fin le ${MaterialLocalizations.of(context).formatShortDate(end)} '
                'à ${TimeOfDay.fromDateTime(end).format(context)}',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            if (e.message.trim().isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: Padding(
                  padding: PulseTheme.pagePadding,
                  child: Text(e.message),
                ),
              ),
            const SizedBox(height: 24),
            Text('Participants', style: theme.textTheme.titleLarge),
            if (_error != null)
              ListTile(
                title: Text(_error!),
                trailing: IconButton(
                  tooltip: 'Réessayer',
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                ),
              )
            else if (participants == null)
              const Center(child: CircularProgressIndicator())
            else if (participants.isEmpty)
              const Text('Aucun membre à afficher.')
            else ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final status in ['GOING', 'NOT_GOING', null])
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${byStatus[status]?.length ?? 0}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                groups[status]!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              for (final group in groups.entries)
                if (byStatus[group.key] case final people?)
                  Card(
                    margin: const EdgeInsets.only(top: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${group.value} (${people.length})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.primary,
                            ),
                          ),
                          for (final person in people) _ParticipantTile(person),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OccurrenceBanner extends StatelessWidget {
  const _OccurrenceBanner({required this.event});

  final NextEventModel event;

  @override
  Widget build(BuildContext context) {
    final image = event.categoryImageUrl?.trim();
    return ClipRRect(
      borderRadius: PulseTheme.cardRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: PulseTheme.gradient),
              child: image == null || image.isEmpty
                  ? null
                  : Image.network(
                      const ApiConfig().resolveUrl(image),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE60B1020)],
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 160),
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.date} ${event.startDate.year} à ${event.time}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile(this.person);

  final Map<String, dynamic> person;

  @override
  Widget build(BuildContext context) {
    final name = '${person['firstName'] ?? ''} ${person['lastName'] ?? ''}'
        .trim();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: MemberAvatar(
        radius: 18,
        url: person['avatarUrl'] as String?,
        name: name,
      ),
      title: Text(name.isEmpty ? 'Membre' : name),
    );
  }
}
