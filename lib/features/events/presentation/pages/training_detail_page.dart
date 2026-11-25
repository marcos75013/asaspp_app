import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/member_avatar.dart';
import '../../../home/data/models/next_event_model.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEvent ? 'Événement' : 'Entraînement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(e.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('${e.date} ${e.startDate.year} à ${e.time}'),
          if (e.endDate != null)
            Text(
              'Fin : ${e.endDate!.day.toString().padLeft(2, '0')}/${e.endDate!.month.toString().padLeft(2, '0')}/${e.endDate!.year} à ${e.endDate!.hour.toString().padLeft(2, '0')}h${e.endDate!.minute.toString().padLeft(2, '0')}',
            ),
          if (e.site.trim().isNotEmpty) Text(e.site),
          if (e.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(e.message),
            ),
          const SizedBox(height: 24),
          Text('Participants', style: Theme.of(context).textTheme.titleLarge),
          if (_error != null)
            ListTile(
              title: Text(_error!),
              trailing: IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            )
          else if (participants == null)
            const Center(child: CircularProgressIndicator())
          else if (participants.isEmpty)
            const Text('Aucun membre à afficher.')
          else ...[
            for (final group in [
              ('Présents', 'GOING'),
              ('Absents', 'NOT_GOING'),
              ('Peut-être', 'MAYBE'),
              ('Liste d’attente', 'WAITLISTED'),
              ('Sans réponse', null),
            ])
              if (participants.any((p) => p['status'] == group.$2)) ...[
                const SizedBox(height: 16),
                Text(
                  '${group.$1} (${participants.where((p) => p['status'] == group.$2).length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final person in participants.where(
                  (p) => p['status'] == group.$2,
                ))
                  ListTile(
                    leading: MemberAvatar(
                      radius: 22,
                      url: person['avatarUrl'] as String?,
                      name:
                          '${person['firstName'] ?? ''} ${person['lastName'] ?? ''}',
                    ),
                    title: Text(
                      '${person['firstName'] ?? ''} ${person['lastName'] ?? ''}'
                              .trim()
                              .isEmpty
                          ? 'Membre'
                          : '${person['firstName'] ?? ''} ${person['lastName'] ?? ''}'
                                .trim(),
                    ),
                  ),
              ],
          ],
        ],
      ),
    );
  }
}
