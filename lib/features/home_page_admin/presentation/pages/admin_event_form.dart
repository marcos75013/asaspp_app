import 'package:flutter/material.dart';
import '../../data/admin_api.dart';

class AdminEventForm extends StatefulWidget {
  final bool training;
  final AdminApi? api;
  const AdminEventForm({super.key, required this.training, this.api});
  @override
  State<AdminEventForm> createState() => _AdminEventFormState();
}

class _AdminEventFormState extends State<AdminEventForm> {
  late final api = widget.api ?? AdminApi();
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      location = TextEditingController(),
      description = TextEditingController();
  DateTime? start, end, until;
  List<Map<String, dynamic>> categories = [];
  int? categoryId;
  bool loading = false,
      saving = false,
      published = true,
      attendance = false,
      recurring = false;
  String frequency = 'WEEKLY';
  int recurrenceInterval = 1;
  final recurrenceDays = <String>{};
  static const weekdays = {
    'MONDAY': 'Lun.',
    'TUESDAY': 'Mar.',
    'WEDNESDAY': 'Mer.',
    'THURSDAY': 'Jeu.',
    'FRIDAY': 'Ven.',
    'SATURDAY': 'Sam.',
    'SUNDAY': 'Dim.',
  };
  String? error;
  @override
  void initState() {
    super.initState();
    if (!widget.training) loadCategories();
  }

  Future<void> loadCategories() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await api.list('/api/event-categories');
      if (mounted) setState(() => categories = data);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Impossible de charger les types d’événement.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    title.dispose();
    location.dispose();
    description.dispose();
    super.dispose();
  }

  Future<DateTime?> pickDate(DateTime? value, {bool withTime = true}) async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (day == null || !mounted) return null;
    if (!withTime) return day;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value ?? now),
    );
    if (time == null) return null;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  String label(DateTime? value, {bool dateOnly = false}) => value == null
      ? 'Choisir'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}${dateOnly ? '' : ' à ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'}';
  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    if (start == null ||
        (!widget.training && categoryId == null) ||
        (recurring && until == null)) {
      setState(
        () => error =
            'Renseignez la date, le type et la fin de récurrence si nécessaire.',
      );
      return;
    }
    if (recurring && until!.isBefore(DateUtils.dateOnly(start!))) {
      setState(
        () =>
            error = 'La fin de récurrence doit être le jour du début ou après.',
      );
      return;
    }
    if (end != null && end!.isBefore(start!)) {
      setState(() => error = 'La fin doit être après le début.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await api.save('/api/events', {
        'eventKind': widget.training ? 'TRAINING' : 'EVENT',
        'title': title.text.trim(),
        'location': location.text.trim(),
        'description': widget.training ? '' : description.text.trim(),
        'categoryId': widget.training ? null : categoryId,
        'category': '',
        'startDate': start!.toIso8601String(),
        'endDate': widget.training ? null : end?.toIso8601String(),
        'published': published,
        'attendanceTrackingEnabled': attendance,
        'capacity': null,
        'recurrenceFrequency': recurring ? frequency : null,
        'recurrenceInterval': recurring ? recurrenceInterval : null,
        'recurrenceUntil': recurring
            ? '${until!.year.toString().padLeft(4, '0')}-${until!.month.toString().padLeft(2, '0')}-${until!.day.toString().padLeft(2, '0')}'
            : null,
        'recurrenceDays': recurring && frequency == 'WEEKLY'
            ? weekdays.keys.where(recurrenceDays.contains).toList()
            : <String>[],
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enregistré.')));
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Impossible de créer cet élément. Vérifiez vos droits et les informations saisies.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.training ? 'Créer un entraînement' : 'Créer un événement',
      ),
    ),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          TextFormField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Le titre est obligatoire.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: location,
            decoration: const InputDecoration(
              labelText: 'Lieu',
              border: OutlineInputBorder(),
            ),
          ),
          if (!widget.training) ...[
            const SizedBox(height: 16),
            if (loading)
              const CircularProgressIndicator()
            else
              DropdownButtonFormField<int>(
                initialValue: categoryId,
                decoration: const InputDecoration(
                  labelText: 'Type d’événement',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c['id'] as int,
                        child: Text(c['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => categoryId = v),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          ListTile(
            title: const Text('Début'),
            subtitle: Text(label(start)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final v = await pickDate(start);
              if (v != null) setState(() => start = v);
            },
          ),
          if (!widget.training)
            ListTile(
              title: const Text('Fin (facultative)'),
              subtitle: Text(label(end)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final v = await pickDate(end);
                if (v != null) setState(() => end = v);
              },
            ),
          if (widget.training) ...[
            SwitchListTile(
              title: const Text('Entraînement récurrent'),
              value: recurring,
              onChanged: (v) => setState(() => recurring = v),
            ),
            if (recurring) ...[
              DropdownButtonFormField<String>(
                initialValue: frequency,
                items: const [
                  DropdownMenuItem(
                    value: 'WEEKLY',
                    child: Text('Hebdomadaire'),
                  ),
                  DropdownMenuItem(value: 'MONTHLY', child: Text('Mensuelle')),
                ],
                onChanged: (v) => setState(() => frequency = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: recurrenceInterval,
                decoration: InputDecoration(
                  labelText: frequency == 'WEEKLY'
                      ? 'Toutes les N semaines'
                      : 'Tous les N mois',
                ),
                items: [
                  for (var interval = 1; interval <= 12; interval++)
                    DropdownMenuItem(value: interval, child: Text('$interval')),
                ],
                onChanged: (value) =>
                    setState(() => recurrenceInterval = value!),
              ),
              if (frequency == 'WEEKLY') ...[
                const SizedBox(height: 12),
                const Text('Jours de la semaine'),
                const Text(
                  'Sans sélection, la série reprend le jour de début.',
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final day in weekdays.entries)
                      FilterChip(
                        label: Text(day.value),
                        selected: recurrenceDays.contains(day.key),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            recurrenceDays.add(day.key);
                          } else {
                            recurrenceDays.remove(day.key);
                          }
                        }),
                      ),
                  ],
                ),
              ],
              ListTile(
                title: const Text('Répéter jusqu’au'),
                subtitle: Text(label(until, dateOnly: true)),
                onTap: () async {
                  final v = await pickDate(until, withTime: false);
                  if (v != null) setState(() => until = v);
                },
              ),
            ],
          ],
          SwitchListTile(
            title: const Text('Visible par les membres'),
            value: published,
            onChanged: (v) => setState(() => published = v),
          ),
          SwitchListTile(
            title: const Text('Suivi des présences'),
            value: attendance,
            onChanged: (v) => setState(() => attendance = v),
          ),
          ElevatedButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Enregistrement…' : 'Créer'),
          ),
        ],
      ),
    ),
  );
}
