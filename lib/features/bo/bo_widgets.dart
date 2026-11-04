import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/data/association_repository.dart';
import '../connected/data/club_api.dart';
export '../connected/data/club_api.dart'
    show ClubApi, Json, records, label, readableError;
export '../../core/data/association_repository.dart' show repositoryOf;

Future<T?> boOpen<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
String person(Json row) =>
    '${label(row, 'firstName')} ${label(row, 'lastName')}'.trim();
String display(dynamic value) =>
    value == null || '$value'.isEmpty ? 'Non renseigné' : '$value';
String boLabel(dynamic value) =>
    const {
      'ACTIVE': 'Active',
      'PENDING': 'En attente',
      'SUSPENDED': 'Suspendue',
      'EXPIRED': 'Expirée',
      'ADMIN': 'Administrateur',
      'MEMBER': 'Membre',
      'MEDICAL_CERTIFICATE': 'Certificat médical',
      'LICENSE': 'Licence',
      'OTHER': 'Autre',
      'UNVERIFIED': 'À vérifier',
      'EXPIRING': 'Expire bientôt',
      'GOING': 'Inscrit',
      'WAITLISTED': 'Liste d’attente',
      'MAYBE': 'Peut-être',
      'NOT_GOING': 'Ne vient pas',
      'PRESENT': 'Présent',
      'ABSENT': 'Absent',
      'UNMARKED': 'Non pointé',
      'DRAFT': 'Brouillon',
      'READY': 'Prête',
      'COMPLETED': 'Terminée',
      'CANCELLED': 'Annulée',
      'AVAILABLE': 'Disponible',
      'RESERVED': 'Réservée',
      'SOLD': 'Vendue',
      'GIVEN': 'Donnée',
      'CLOSED': 'Clôturée',
      'WEEKLY': 'Hebdomadaire',
      'MONTHLY': 'Mensuelle',
      'OCCURRENCE': 'Cette occurrence',
      'SERIES': 'Cette occurrence et les suivantes',
      'MONDAY': 'Lundi',
      'TUESDAY': 'Mardi',
      'WEDNESDAY': 'Mercredi',
      'THURSDAY': 'Jeudi',
      'FRIDAY': 'Vendredi',
      'SATURDAY': 'Samedi',
      'SUNDAY': 'Dimanche',
    }[value] ??
    display(value);
Map<String, String> choices(List<String> values) => {
  for (final v in values) v: boLabel(v),
};

Future<bool> boRun(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } catch (e) {
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(readableError(e))));
    return false;
  }
}

Future<bool> boConfirm(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    ) ??
    false;
Future<void> boDelete(
  BuildContext context,
  ClubApi api,
  String path,
  Future<void> Function() reload, {
  Map<String, dynamic>? query,
}) async {
  if (!await boConfirm(
    context,
    'Supprimer cet élément ?',
    'Cette suppression sera enregistrée pour l’association.',
  ))
    return;
  if (!context.mounted) return;
  if (await boRun(context, () async {
    await api.request(path, method: 'DELETE', query: query);
  }))
    await reload();
}

Future<List<MultipartFile>> pickBoFiles({
  bool images = false,
  bool multiple = false,
  int maxMB = 10,
}) async {
  final result = await FilePicker.pickFiles(
    type: images ? FileType.image : FileType.any,
    allowMultiple: multiple,
    withData: true,
  );
  if (result == null) return [];
  return result.files.map((f) {
    final bytes = f.bytes;
    if (bytes == null || bytes.isEmpty || bytes.length > maxMB * 1024 * 1024)
      throw StateError('Fichier vide ou supérieur à $maxMB Mo.');
    final mime =
        lookupMimeType(f.name, headerBytes: bytes) ??
        'application/octet-stream';
    if (images && !['image/jpeg', 'image/png', 'image/webp'].contains(mime))
      throw StateError('Choisissez une image JPEG, PNG ou WebP.');
    return MultipartFile.fromBytes(
      bytes,
      filename: f.name,
      contentType: DioMediaType.parse(mime),
    );
  }).toList();
}

Future<void> boDownload(
  BuildContext context,
  ClubApi api,
  String path,
  Json doc,
) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null
      ? const Rect.fromLTWH(0, 0, 1, 1)
      : box.localToGlobal(Offset.zero) & box.size;
  await boRun(context, () async {
    final bytes = await api.request(path, responseType: ResponseType.bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(List<int>.from(bytes)),
            mimeType: label(doc, 'contentType', 'application/octet-stream'),
          ),
        ],
        fileNameOverrides: [label(doc, 'originalFilename', 'document')],
        sharePositionOrigin: origin,
      ),
    );
  });
}

class BoList extends StatefulWidget {
  final String title;
  final Future<List<Json>> Function(ClubApi) load;
  final Widget Function(BuildContext, ClubApi, Json, Future<void> Function())
  tile;
  final Future<void> Function(BuildContext, ClubApi, Future<void> Function())?
  add;
  final List<Widget> actions;
  const BoList({
    super.key,
    required this.title,
    required this.load,
    required this.tile,
    this.add,
    this.actions = const [],
  });
  @override
  State<BoList> createState() => _BoListState();
}

class _BoListState extends State<BoList> {
  ClubApi? _api;
  List<Json> _rows = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  int _generation = 0;
  bool _adding = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = await repositoryOf(context).api();
      final rows = await widget.load(api);
      if (mounted && generation == _generation)
        setState(() {
          _api = api;
          _rows = rows;
          _loading = false;
        });
    } catch (e) {
      if (mounted && generation == _generation)
        setState(() {
          _error = readableError(e);
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows
        .where(
          (r) =>
              r.values.join(' ').toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ...widget.actions,
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: widget.add == null || _api == null
          ? null
          : FloatingActionButton(
              onPressed: _adding
                  ? null
                  : () async {
                      setState(() => _adding = true);
                      await boRun(
                        context,
                        () => widget.add!(context, _api!, _load),
                      );
                      if (mounted) setState(() => _adding = false);
                    },
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _loading || _error != null || rows.isEmpty
                ? Center(
                    child: DataStatus(
                      loading: _loading,
                      error: _error,
                      empty: 'Aucun élément à afficher.',
                      reload: _load,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: rows.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          widget.tile(context, _api!, rows[i], _load),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class BoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const BoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.children = const [],
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!)],
          if (children.isNotEmpty) ...[const SizedBox(height: 12), ...children],
        ],
      ),
    ),
  );
}

class BoAction extends StatefulWidget {
  final String label;
  final Future<void> Function() action;
  const BoAction(this.label, this.action, {super.key});
  @override
  State<BoAction> createState() => _BoActionState();
}

class _BoActionState extends State<BoAction> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: _busy
        ? null
        : () async {
            setState(() => _busy = true);
            await boRun(context, widget.action);
            if (mounted) setState(() => _busy = false);
          },
    child: Text(_busy ? 'En cours…' : widget.label),
  );
}

class BoField {
  final String key, label, kind;
  final bool required;
  final Map<String, String>? options;
  final num? min, max;
  const BoField(
    this.key,
    this.label, {
    this.kind = 'text',
    this.required = false,
    this.options,
    this.min,
    this.max,
  });
}

String? validateBoFields(List<BoField> fields, Json data) {
  for (final f in fields) {
    final v = data[f.key];
    final empty =
        v == null ||
        (v is String && v.trim().isEmpty) ||
        (v is List && v.isEmpty);
    if (f.required && empty) return '${f.label} : ce champ est obligatoire.';
    if (empty) continue;
    if (f.options != null && f.kind != 'multi' && !f.options!.containsKey('$v'))
      return '${f.label} : choisissez une valeur disponible.';
    if (f.kind == 'number' || f.kind == 'integer') {
      final n = v is num ? v : num.tryParse('$v');
      if (n == null ||
          !n.isFinite ||
          (f.min != null && n < f.min!) ||
          (f.max != null && n > f.max!) ||
          (f.kind == 'integer' && n != n.round()))
        return '${f.label} : valeur numérique invalide.';
    }
    if (f.kind == 'email' &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch('$v'))
      return '${f.label} : adresse invalide.';
    if ((f.kind == 'date' || f.kind == 'datetime') &&
        DateTime.tryParse('$v') == null)
      return '${f.label} : date invalide.';
  }
  return null;
}

class BoForm extends StatefulWidget {
  final String title;
  final List<BoField> fields;
  final Json initial;
  final Future<void> Function(Json) save;
  final String? help;
  final String? Function(Json)? validate;
  const BoForm({
    super.key,
    required this.title,
    required this.fields,
    required this.save,
    this.initial = const {},
    this.help,
    this.validate,
  });
  @override
  State<BoForm> createState() => _BoFormState();
}

class _BoFormState extends State<BoForm> {
  final _form = GlobalKey<FormState>();
  late Json _data;
  final Map<String, TextEditingController> _controllers = {};
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _data = Map.of(widget.initial);
    for (final f in widget.fields) {
      if (f.options == null &&
          [
            'text',
            'multiline',
            'number',
            'integer',
            'date',
            'datetime',
            'email',
            'csv',
          ].contains(f.kind))
        _controllers[f.key] = TextEditingController(
          text: f.kind == 'csv' && _data[f.key] is List
              ? (_data[f.key] as List).join(', ')
              : '${_data[f.key] ?? ''}',
        );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _date(BoField f) async {
    final initial =
        DateTime.tryParse(_controllers[f.key]!.text) ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (d == null || !mounted) return;
    DateTime result = d;
    if (f.kind == 'datetime') {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (t == null || !mounted) return;
      result = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    }
    setState(
      () => _controllers[f.key]!.text = f.kind == 'date'
          ? result.toIso8601String().substring(0, 10)
          : result.toIso8601String(),
    );
  }

  Json value() {
    final data = Json.from(_data);
    for (final f in widget.fields) {
      final c = _controllers[f.key];
      if (c != null) {
        final t = c.text.trim();
        data[f.key] = ['number', 'integer'].contains(f.kind)
            ? (t.isEmpty ? null : (num.tryParse(t.replaceAll(',', '.')) ?? t))
            : f.kind == 'csv'
            ? t
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList()
            : t.isEmpty
            ? null
            : t;
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.help != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(widget.help!),
            ),
          ...widget.fields.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _field(f),
            ),
          ),
          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    if (!_form.currentState!.validate()) return;
                    final data = value();
                    final message =
                        validateBoFields(widget.fields, data) ??
                        widget.validate?.call(data);
                    if (message != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                      return;
                    }
                    setState(() => _busy = true);
                    final ok = await boRun(context, () => widget.save(data));
                    if (!mounted) return;
                    if (ok)
                      Navigator.pop(context, true);
                    else
                      setState(() => _busy = false);
                  },
            child: Text(_busy ? 'Enregistrement…' : 'Enregistrer'),
          ),
        ],
      ),
    ),
  );
  Widget _field(BoField f) {
    if (f.kind == 'bool')
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(f.label),
        value: _data[f.key] == true,
        onChanged: _busy ? null : (v) => setState(() => _data[f.key] = v),
      );
    if (f.kind == 'multi') {
      final selected = List<String>.from(_data[f.key] ?? []);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f.label),
          Wrap(
            spacing: 8,
            children: [
              for (final e in f.options!.entries)
                FilterChip(
                  label: Text(e.value),
                  selected: selected.contains(e.key),
                  onSelected: _busy
                      ? null
                      : (v) => setState(() {
                          v ? selected.add(e.key) : selected.remove(e.key);
                          _data[f.key] = selected;
                        }),
                ),
            ],
          ),
        ],
      );
    }
    if (f.options != null) {
      final current = _data[f.key]?.toString();
      return DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: f.options!.containsKey(current) ? current : null,
        decoration: InputDecoration(
          labelText: f.label,
          border: const OutlineInputBorder(),
        ),
        items: [
          if (!f.required)
            const DropdownMenuItem(value: '', child: Text('Aucun')),
          for (final e in f.options!.entries)
            DropdownMenuItem(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: _busy ? null : (v) => _data[f.key] = v == '' ? null : v,
        validator: (v) => f.required && (v == null || v.isEmpty)
            ? 'Choisissez une valeur.'
            : null,
      );
    }
    final date = f.kind == 'date' || f.kind == 'datetime';
    return TextFormField(
      controller: _controllers[f.key],
      enabled: !_busy,
      readOnly: date,
      onTap: date ? () => _date(f) : null,
      maxLines: f.kind == 'multiline' ? 4 : 1,
      keyboardType: ['number', 'integer'].contains(f.kind)
          ? const TextInputType.numberWithOptions(decimal: true)
          : f.kind == 'email'
          ? TextInputType.emailAddress
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: f.label,
        border: const OutlineInputBorder(),
        suffixIcon: date
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _controllers[f.key]!.clear(),
              )
            : null,
      ),
      validator: (v) {
        final text = v?.trim() ?? '';
        if (f.required && text.isEmpty) return 'Ce champ est obligatoire.';
        if (text.isEmpty) return null;
        if (f.kind == 'email' &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text))
          return 'Adresse email invalide.';
        if (['number', 'integer'].contains(f.kind)) {
          final n = num.tryParse(text.replaceAll(',', '.'));
          if (f.kind == 'integer' && n != null && n != n.round())
            return 'Indiquez un nombre entier.';
          if (n == null ||
              (f.min != null && n < f.min!) ||
              (f.max != null && n > f.max!))
            return 'Valeur numérique hors limites.';
        }
        return null;
      },
    );
  }
}

Future<List<Json>> allBoEvents(ClubApi api, {bool? future}) async {
  final rows = <Json>[];
  int page = 0;
  while (true) {
    final data = await api.request(
      '/api/events',
      query: {
        'page': page++,
        'size': 100,
        if (future != null) 'future': future,
      },
    );
    rows.addAll(records(data['content']));
    if (data['last'] != false) break;
  }
  return rows;
}
