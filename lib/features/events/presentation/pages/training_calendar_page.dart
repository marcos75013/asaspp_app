import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/pulse_theme.dart';
import '../../../home/data/models/next_event_model.dart';
import '../../../home/data/services/mobile_event_api_service.dart';
import 'training_detail_page.dart';

class TrainingCalendarPage extends StatefulWidget {
  final ApiClient? apiClient;
  const TrainingCalendarPage({super.key, this.apiClient});
  @override
  State<TrainingCalendarPage> createState() => _TrainingCalendarPageState();
}

class _TrainingCalendarPageState extends State<TrainingCalendarPage> {
  late final _client = widget.apiClient ?? ApiClient(AuthStorage());
  List<NextEventModel> _trainings = [];
  bool _loading = true;
  String? _error;
  int? _saving;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _trainings = [];
    });
    try {
      final all = <NextEventModel>[];
      var page = 0;
      bool last;
      do {
        final response = await _client.dio.get<Map<String, dynamic>>(
          '/api/mobile/trainings',
          queryParameters: {'page': page++, 'size': 100},
        );
        final data = response.data!;
        all.addAll(
          (data['content'] as List).map(
            (item) =>
                NextEventModel.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
        last = data['last'] == true;
      } while (!last);
      if (mounted) setState(() => _trainings = all);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de charger les entraînements.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(
    NextEventModel event,
    ParticipationStatus status,
  ) async {
    setState(() {
      _saving = event.id;
      _error = null;
    });
    try {
      final result = await MobileEventApiService(
        _client,
      ).setParticipation(event.id, status);
      if (mounted) {
        setState(
          () => _trainings = _trainings
              .map((e) => e.id == event.id ? result : e)
              .toList(),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible d’enregistrer ta réponse.');
      }
    } finally {
      if (mounted) setState(() => _saving = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming =
        _trainings.where((e) => !e.startDate.isBefore(now)).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final past = _trainings.where((e) => e.startDate.isBefore(now)).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final theme = PulseTheme.build(Theme.of(context).brightness);
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Agenda')),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (_error != null)
                  ListTile(
                    title: Text(_error!),
                    trailing: IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                if (_trainings.isEmpty && _error == null)
                  const Text('Aucun entraînement pour le moment.'),
                if (upcoming.isNotEmpty)
                  ..._section('À venir', upcoming, canRespond: true),
                if (past.isNotEmpty)
                  ..._section('Terminés', past, canRespond: false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _section(
    String title,
    List<NextEventModel> events, {
    required bool canRespond,
  }) => [
    Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Builder(
        builder: (context) => Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    for (final event in events)
      _TrainingCard(
        event: event,
        onOpen: () => _open(event),
        canRespond: canRespond,
        onRespond: _saving == null ? (status) => _respond(event, status) : null,
      ),
  ];

  void _open(NextEventModel event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrainingDetailPage(training: event, apiClient: _client),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({
    required this.event,
    required this.onOpen,
    required this.canRespond,
    required this.onRespond,
  });

  final NextEventModel event;
  final VoidCallback onOpen;
  final bool canRespond;
  final ValueChanged<ParticipationStatus>? onRespond;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final accent = dark ? const Color(0xFF80E4D4) : const Color(0xFF006A60);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Tooltip(
                    message: '${event.date} ${event.startDate.year}',
                    child: ExcludeSemantics(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${event.startDate.day}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _shortMonth(event.month),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          [
                            if (event.site.trim().isNotEmpty) event.site,
                            event.time,
                          ].join(' · '),
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                ],
              ),
              TextButton.icon(
                onPressed: onOpen,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: accent,
                  alignment: Alignment.centerLeft,
                ),
                icon: const Icon(Icons.group_outlined, size: 18),
                label: Text(
                  '${event.goingCount} présent(s) · Voir les participants',
                ),
              ),
              if (event.participation == ParticipationStatus.waitlisted)
                const Text('Inscrit sur liste d’attente'),
              if (event.message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(event.message),
                ),
              if (canRespond)
                Row(
                  children: [
                    for (final (status, label) in [
                      (ParticipationStatus.going, 'Présent'),
                      (ParticipationStatus.notGoing, 'Absent'),
                    ]) ...[
                      if (status == ParticipationStatus.notGoing)
                        const SizedBox(width: 8),
                      Expanded(
                        child: Semantics(
                          selected: event.participation == status,
                          child: OutlinedButton(
                            onPressed: onRespond == null
                                ? null
                                : () => onRespond!(status),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: event.participation == status
                                  ? (dark ? Colors.black : Colors.white)
                                  : colors.onSurface,
                              backgroundColor: event.participation == status
                                  ? accent
                                  : null,
                              side: BorderSide(
                                color: event.participation == status
                                    ? accent
                                    : colors.outlineVariant,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(label, textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _shortMonth(String month) => switch (month) {
  'mars' => 'MARS',
  'juin' => 'JUIN',
  'juillet' => 'JUIL',
  _ => month.substring(0, 3).toUpperCase(),
};
