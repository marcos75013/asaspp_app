import 'package:flutter/material.dart';
import '../data/club_api.dart';
import 'club_widgets.dart';
import 'carpools_page.dart';

class ConnectedEvents extends StatefulWidget {
  final ClubApi api;
  final bool carpooling;
  final bool compact;
  const ConnectedEvents({
    super.key,
    required this.api,
    required this.carpooling,
    this.compact = false,
  });
  @override
  State<ConnectedEvents> createState() => _ConnectedEventsState();
}

class _ConnectedEventsState extends State<ConnectedEvents> {
  List<Json> _events = [];
  bool _loading = true, _more = false;
  int _page = 0, _generation = 0;
  String _query = '';
  Object? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool append = false}) async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    final page = append ? _page + 1 : 0;
    try {
      final result = await widget.api.events(page: page, query: _query);
      if (!mounted || generation != _generation) return;
      setState(() {
        _events = [
          if (append) ..._events,
          ...records(
            result['content'],
          ).where((event) => event['published'] == true),
        ];
        _page = page;
        _more = result['last'] == false;
        _loading = false;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  Widget _card(Json event) => EventCard(
    event: event,
    api: widget.api,
    onTap: () async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EventDetails(
            api: widget.api,
            event: event,
            carpooling: widget.carpooling,
          ),
        ),
      );
      if (mounted) _load();
    },
  );

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (!widget.compact) ...[
        const Heading(
          'Les sorties à venir',
          'Retrouvez les événements de votre association.',
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Rechercher un événement',
            prefixIcon: Icon(Icons.search),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            _query = value.trim();
            _load();
          },
        ),
        const SizedBox(height: 20),
      ],
      if (_loading) const LinearProgressIndicator(),
      if (_error != null)
        StatusPanel(
          title: 'Agenda indisponible',
          message: readableError(_error!),
          retry: () => _load(),
        ),
      if (!_loading && _error == null && _events.isEmpty)
        const StatusPanel(
          title: 'La suite se prépare',
          message:
              'Les prochains événements publiés par votre association apparaîtront ici.',
          icon: Icons.event_available_outlined,
        ),
      if (widget.compact && _events.isNotEmpty)
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final event in _events.take(5))
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: constraints.maxWidth.clamp(0, 390).toDouble() - 8,
                      child: _card(event),
                    ),
                  ),
              ],
            ),
          ),
        )
      else
        ..._events.map(_card),
      if (_more && !widget.compact)
        OutlinedButton(
          onPressed: _loading ? null : () => _load(append: true),
          child: const Text('Voir les rendez-vous suivants'),
        ),
    ];
    if (widget.compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: PageBody(children: children),
    );
  }
}

class EventCard extends StatelessWidget {
  final Json event;
  final ClubApi api;
  final VoidCallback onTap;
  const EventCard({
    super.key,
    required this.event,
    required this.api,
    required this.onTap,
  });
  String? get _illustration {
    final category = label(event, 'category').toLowerCase();
    for (final entry in {
      'piscine': 'piscine',
      'mer': 'mer',
      'plongée': 'mer',
      'fosse': 'fosse',
      'carrière': 'carriere',
      'formation': 'formation',
      'apéro': 'apero',
      'stage': 'stage',
    }.entries) {
      if (category.contains(entry.key)) return 'assets/pngs/${entry.value}.png';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['categoryImageUrl'] != null) ...[
              ClubImage(api.imageUrl(event['categoryImageUrl']), height: 128),
              const SizedBox(height: 14),
            ] else if (_illustration != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  _illustration!,
                  width: double.infinity,
                  height: 128,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 14),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Tag(label(event, 'category', 'Rendez-vous')),
                if (event['currentUserStatus'] != null)
                  Tag(participationLabel(event['currentUserStatus'])),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label(event, 'title'),
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              dateLabel(event['startDate']),
              style: const TextStyle(color: teal, fontWeight: FontWeight.w600),
            ),
            if (label(event, 'location').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(label(event, 'location')),
              ),
            const SizedBox(height: 12),
            Text(
              '${event['goingCount'] ?? 0} participant(s)'
              '${event['capacity'] == null ? '' : ' · ${event['capacity']} places au total'}',
              style: const TextStyle(color: Color(0xFF62756F)),
            ),
          ],
        ),
      ),
    ),
  );
}

String participationLabel(dynamic status) => switch (status) {
  'GOING' => 'Inscrit·e',
  'MAYBE' => 'Peut-être',
  'NOT_GOING' => 'Absent·e',
  'WAITLISTED' => 'Liste d’attente',
  _ => 'Sans réponse',
};

class EventDetails extends StatefulWidget {
  final ClubApi api;
  final Json event;
  final bool carpooling;
  const EventDetails({
    super.key,
    required this.api,
    required this.event,
    required this.carpooling,
  });
  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late Json _event = widget.event;
  bool _busy = false;
  Future<void> _respond(String status) async {
    setState(() => _busy = true);
    await runAction(context, () async {
      final result = await widget.api.participate(_event['id'] as int, status);
      if (mounted) setState(() => _event = result);
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Le rendez-vous')),
    body: PageBody(
      children: [
        if (_event['categoryImageUrl'] != null)
          ClubImage(
            widget.api.imageUrl(_event['categoryImageUrl']),
            height: 230,
          ),
        Heading(label(_event, 'title'), dateLabel(_event['startDate'])),
        if (_event['endDate'] != null)
          Text('Jusqu’au ${dateLabel(_event['endDate'])}'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place_outlined),
          title: Text(label(_event, 'location', 'Lieu à préciser')),
        ),
        Text(
          label(_event, 'description', 'Aucune précision supplémentaire.'),
          style: const TextStyle(height: 1.6),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vous en êtes ?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_event['goingCount']} inscrit(s) · ${participationLabel(_event['currentUserStatus'])}',
                ),
                if (_event['capacity'] != null)
                  Text(
                    'Capacité : ${_event['capacity']} · '
                    '${_event['waitlistedCount'] ?? 0} en attente',
                  ),
                const SizedBox(height: 16),
                if (_busy) const LinearProgressIndicator(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy ? null : () => _respond('GOING'),
                      icon: const Icon(Icons.check),
                      label: const Text('Je participe'),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : () => _respond('MAYBE'),
                      child: const Text('Peut-être'),
                    ),
                    TextButton(
                      onPressed: _busy ? null : () => _respond('NOT_GOING'),
                      child: const Text('Je ne viens pas'),
                    ),
                  ],
                ),
                if (_event['currentUserStatus'] == 'WAITLISTED')
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Votre demande est enregistrée sur la liste d’attente.',
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.carpooling)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.directions_car_outlined, color: teal),
              title: const Text('Faire la route ensemble'),
              subtitle: const Text('Proposer un trajet ou réserver une place'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => openPage(
                context,
                CarpoolsPage(api: widget.api, event: _event),
              ),
            ),
          ),
      ],
    ),
  );
}
