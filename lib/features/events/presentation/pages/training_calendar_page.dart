import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../home/data/models/next_event_model.dart';
import '../../../home/data/services/mobile_event_api_service.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
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
              if (upcoming.isNotEmpty) ...[
                const Text(
                  'À venir',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ...upcoming.map((e) => _card(e, true)),
              ],
              if (past.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Terminés',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ...past.map((e) => _card(e, false)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(NextEventModel event, bool future) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('${event.date} ${event.startDate.year} à ${event.time}'),
          if (event.site != event.title) Text(event.site),
          if (event.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(event.message),
          ],
          if (future)
            Wrap(
              spacing: 8,
              children: [
                for (final option in [
                  (ParticipationStatus.going, 'Présent'),
                  (ParticipationStatus.notGoing, 'Absent'),
                ])
                  OutlinedButton(
                    onPressed: _saving == null
                        ? () => _respond(event, option.$1)
                        : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: event.participation == option.$1
                          ? Colors.green.withValues(alpha: .18)
                          : null,
                    ),
                    child: Text(option.$2),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}
