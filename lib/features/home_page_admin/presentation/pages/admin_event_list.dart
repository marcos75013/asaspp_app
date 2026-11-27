import 'package:flutter/material.dart';

import '../../data/admin_api.dart';
import 'admin_event_form.dart';

class AdminEventList extends StatefulWidget {
  final bool training;
  final AdminApi api;

  const AdminEventList({super.key, required this.training, required this.api});

  @override
  State<AdminEventList> createState() => _AdminEventListState();
}

class _AdminEventListState extends State<AdminEventList> {
  late Future<({List<Map<String, dynamic>> items, bool last})> _result;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _result = _load();
  }

  Future<({List<Map<String, dynamic>> items, bool last})> _load() =>
      widget.api.eventPage(training: widget.training, page: _page);

  void _reload(int page) => setState(() {
    _page = page;
    _result = _load();
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.training ? 'Entraînements' : 'Événements'),
    ),
    body: FutureBuilder(
      future: _result,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) {
          return Center(
            child: TextButton(
              onPressed: () => _reload(_page),
              child: const Text('Chargement impossible. Réessayer'),
            ),
          );
        }
        return ListView(
          children: [
            if (data.items.isEmpty)
              const ListTile(title: Text('Aucune date à modifier.')),
            for (final event in data.items)
              ListTile(
                title: Text(event['title'] as String),
                subtitle: Text(
                  _dateLabel(context, event['startDate'] as String?),
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AdminEventForm(
                        training: widget.training,
                        api: widget.api,
                        occurrence: event,
                      ),
                    ),
                  );
                  if (mounted) _reload(_page);
                },
              ),
            if (_page > 0 || !data.last)
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () => _reload(_page - 1),
                      child: const Text('Page précédente'),
                    ),
                  if (!data.last)
                    TextButton(
                      onPressed: () => _reload(_page + 1),
                      child: const Text('Page suivante'),
                    ),
                ],
              ),
          ],
        );
      },
    ),
  );

  String _dateLabel(BuildContext context, String? raw) {
    final date = DateTime.tryParse(raw ?? '')?.toLocal();
    if (date == null) return '';
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatShortDate(date)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
  }
}
