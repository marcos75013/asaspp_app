import 'package:flutter/material.dart';
import '../data/club_api.dart';
import 'club_widgets.dart';

class CarpoolsPage extends StatefulWidget {
  final ClubApi api;
  final Json event;
  const CarpoolsPage({super.key, required this.api, required this.event});
  @override
  State<CarpoolsPage> createState() => _CarpoolsPageState();
}

class _CarpoolsPageState extends State<CarpoolsPage> {
  late Future<List<Json>> _future = _fetch();
  final Set<int> _busy = {};
  Future<List<Json>> _fetch() =>
      widget.api.list('/api/events/${widget.event['id']}/carpools');
  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _future = future);
    await future;
  }

  Future<void> _action(Json trip, String suffix, String method) async {
    final id = trip['id'] as int;
    setState(() => _busy.add(id));
    await runAction(context, () async {
      await widget.api.request('/api/carpools/$id$suffix', method: method);
      if (mounted) await _refresh();
    });
    if (mounted) setState(() => _busy.remove(id));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Covoiturage')),
    body: RefreshIndicator(
      onRefresh: () => runAction(context, _refresh),
      child: PageBody(
        children: [
          Heading(
            'La route est plus belle ensemble.',
            label(widget.event, 'title'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Proposer ou chercher un trajet'),
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      CarpoolForm(api: widget.api, event: widget.event),
                ),
              );
              if (saved == true && context.mounted) {
                runAction(context, _refresh);
              }
            },
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Json>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator();
              }
              if (snapshot.hasError) {
                return StatusPanel(
                  title: 'Trajets indisponibles',
                  message: readableError(snapshot.error!),
                  retry: () => runAction(context, _refresh),
                );
              }
              final trips = snapshot.data ?? [];
              if (trips.isEmpty) {
                return const StatusPanel(
                  title: 'Le premier départ, c’est vous ?',
                  message: 'Proposez votre trajet aux autres participants.',
                  icon: Icons.directions_car_outlined,
                );
              }
              return Column(
                children: trips.map((trip) {
                  final own = trip['ownedByCurrentUser'] == true;
                  final booked = trip['bookedByCurrentUser'] == true;
                  final busy = _busy.contains(trip['id']);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Tag(
                              trip['type'] == 'OFFER'
                                  ? 'Trajet proposé'
                                  : 'Recherche de trajet',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            label(trip, 'departureLocation'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(dateLabel(trip['departureTime'])),
                          const SizedBox(height: 12),
                          Text(
                            '${label(trip, 'authorFirstName')} ${label(trip, 'authorLastName')}',
                          ),
                          Text(
                            '${trip['availableSeatCount']} place(s) disponible(s)',
                          ),
                          if (label(trip, 'note').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(label(trip, 'note')),
                            ),
                          const SizedBox(height: 14),
                          if (own) ...[
                            OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final saved = await Navigator.of(context)
                                          .push<bool>(
                                            MaterialPageRoute(
                                              builder: (_) => CarpoolForm(
                                                api: widget.api,
                                                event: widget.event,
                                                trip: trip,
                                              ),
                                            ),
                                          );
                                      if (saved == true && context.mounted) {
                                        runAction(context, _refresh);
                                      }
                                    },
                              child: const Text('Modifier mon trajet'),
                            ),
                            if (trip['type'] == 'OFFER')
                              TextButton(
                                onPressed: () => openPage(
                                  context,
                                  PassengerPage(
                                    api: widget.api,
                                    tripId: trip['id'] as int,
                                  ),
                                ),
                                child: const Text('Voir mes passagers'),
                              ),
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Annuler ce trajet ?',
                                          ),
                                          content: const Text(
                                            'Les réservations associées seront annulées.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Conserver'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Annuler le trajet',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        _action(trip, '', 'DELETE');
                                      }
                                    },
                              child: const Text('Annuler mon trajet'),
                            ),
                          ] else if (trip['type'] == 'OFFER')
                            FilledButton(
                              onPressed:
                                  busy ||
                                      (!booked &&
                                          (trip['availableSeatCount'] as num) <=
                                              0)
                                  ? null
                                  : () => _action(
                                      trip,
                                      booked ? '/bookings/mine' : '/bookings',
                                      booked ? 'DELETE' : 'POST',
                                    ),
                              child: Text(
                                booked
                                    ? 'Annuler ma réservation'
                                    : 'Réserver une place',
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class CarpoolForm extends StatefulWidget {
  final ClubApi api;
  final Json event;
  final Json? trip;
  const CarpoolForm({
    super.key,
    required this.api,
    required this.event,
    this.trip,
  });
  @override
  State<CarpoolForm> createState() => _CarpoolFormState();
}

class _CarpoolFormState extends State<CarpoolForm> {
  final _form = GlobalKey<FormState>();
  late final _place = TextEditingController(
    text: widget.trip?['departureLocation'],
  );
  late final _note = TextEditingController(text: widget.trip?['note']);
  late final _seats = TextEditingController(
    text: '${widget.trip?['seatCount'] ?? 3}',
  );
  late String _type = widget.trip?['type'] ?? 'OFFER';
  late DateTime _departure =
      DateTime.tryParse(widget.trip?['departureTime'] ?? '') ??
      (DateTime.tryParse(label(widget.event, 'startDate')) ??
              DateTime.now().add(const Duration(days: 1)))
          .subtract(const Duration(hours: 1));
  bool _busy = false;
  @override
  void dispose() {
    _place.dispose();
    _note.dispose();
    _seats.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_departure.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un départ dans le futur.')),
      );
      return;
    }
    setState(() => _busy = true);
    await runAction(context, () async {
      await widget.api.request(
        widget.trip == null
            ? '/api/events/${widget.event['id']}/carpools'
            : '/api/carpools/${widget.trip!['id']}',
        method: widget.trip == null ? 'POST' : 'PUT',
        data: {
          'type': _type,
          'departureLocation': _place.text.trim(),
          'departureTime': _departure.toIso8601String(),
          'seatCount': int.parse(_seats.text),
          'note': _note.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context, true);
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mon trajet')),
    body: Form(
      key: _form,
      child: PageBody(
        children: [
          const Heading(
            'Un départ partagé',
            'Renseignez les détails pour les autres membres.',
          ),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type de trajet'),
            items: const [
              DropdownMenuItem(
                value: 'OFFER',
                child: Text('Je propose des places'),
              ),
              DropdownMenuItem(
                value: 'REQUEST',
                child: Text('Je cherche un trajet'),
              ),
            ],
            onChanged: _busy ? null : (value) => setState(() => _type = value!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _place,
            maxLength: 180,
            decoration: const InputDecoration(labelText: 'Lieu de départ'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Indiquez un lieu.'
                : null,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(dateLabel(_departure)),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _busy
                ? null
                : () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _departure.isBefore(now) ? now : _departure,
                      firstDate: DateTime(now.year, now.month, now.day),
                      lastDate: DateTime(now.year + 10),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_departure),
                    );
                    if (time != null && mounted) {
                      setState(
                        () => _departure = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _seats,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nombre de places passagers',
            ),
            validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1
                ? 'Indiquez au moins une place.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _note,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Un détail utile ?'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? 'Enregistrement…' : 'Enregistrer le trajet'),
          ),
        ],
      ),
    ),
  );
}

class PassengerPage extends StatefulWidget {
  final ClubApi api;
  final int tripId;
  const PassengerPage({super.key, required this.api, required this.tripId});
  @override
  State<PassengerPage> createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
  late Future<List<Json>> _future = widget.api.list(
    '/api/carpools/${widget.tripId}/passengers',
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mes passagers')),
    body: FutureBuilder<List<Json>>(
      future: _future,
      builder: (context, snapshot) => PageBody(
        children: [
          if (snapshot.connectionState != ConnectionState.done)
            const LinearProgressIndicator()
          else if (snapshot.hasError)
            StatusPanel(
              title: 'Passagers indisponibles',
              message: readableError(snapshot.error!),
              retry: () => setState(
                () => _future = widget.api.list(
                  '/api/carpools/${widget.tripId}/passengers',
                ),
              ),
            )
          else if (snapshot.data!.isEmpty)
            const StatusPanel(
              title: 'Aucune réservation',
              message: 'Vos passagers apparaîtront ici.',
            )
          else
            ...snapshot.data!.map(
              (p) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(
                    '${label(p, 'firstName')} ${label(p, 'lastName')}',
                  ),
                  subtitle: Text(label(p, 'email')),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
