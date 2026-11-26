import 'package:flutter/material.dart';
import '../../data/admin_api.dart';

class AdminTextResourcesPage extends StatefulWidget {
  final bool payments;
  final AdminApi? api;
  const AdminTextResourcesPage({super.key, required this.payments, this.api});
  @override
  State<AdminTextResourcesPage> createState() => _AdminTextResourcesPageState();
}

class _AdminTextResourcesPageState extends State<AdminTextResourcesPage> {
  late final AdminApi api = widget.api ?? AdminApi();
  final title = TextEditingController();
  final content = TextEditingController();
  final signature = TextEditingController();
  final key = GlobalKey<FormState>();
  List<Map<String, dynamic>> items = [];
  bool loading = true, saving = false, published = true;
  String? error;
  int? editing;
  String get path => widget.payments
      ? '/api/payment-links'
      : '/api/admin-association/messages';
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    signature.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await api.list(path);
      if (mounted) setState(() => items = result);
    } catch (_) {
      if (mounted) setState(() => error = 'Impossible de charger les données.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void clear() {
    title.clear();
    content.clear();
    signature.clear();
    setState(() {
      editing = null;
      published = true;
    });
  }

  Future<void> save() async {
    if (!key.currentState!.validate() || saving) return;
    setState(() {
      saving = true;
      error = null;
    });
    final data = widget.payments
        ? {
            'title': title.text.trim(),
            'url': content.text.trim(),
            'published': published,
          }
        : {
            'title': title.text.trim(),
            'content': content.text.trim(),
            'signature': signature.text.trim().isEmpty
                ? null
                : signature.text.trim(),
            'published': published,
          };
    try {
      await api.save(path, data, id: editing);
      if (!mounted) return;
      clear();
      await load();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enregistré.')));
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Enregistrement impossible. Vérifiez vos droits et réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> remove(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Supprimer « ${item['title']} » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await api.delete(path, item['id'] as int);
      await load();
    } catch (_) {
      if (mounted) setState(() => error = 'Suppression impossible.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.payments ? 'Liens de paiement' : 'Messages association',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),
        Form(
          key: key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                editing == null ? 'Ajouter' : 'Modifier',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                maxLength: 150,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Le titre est obligatoire.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: content,
                decoration: InputDecoration(
                  labelText: widget.payments ? 'Lien de paiement' : 'Message',
                  border: const OutlineInputBorder(),
                ),
                maxLines: widget.payments ? 1 : 5,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Ce champ est obligatoire.';
                  if (widget.payments) {
                    final u = Uri.tryParse(s);
                    if (u == null ||
                        !['http', 'https'].contains(u.scheme.toLowerCase()) ||
                        u.host.isEmpty ||
                        u.userInfo.isNotEmpty) {
                      return 'Saisissez un lien HTTP ou HTTPS valide.';
                    }
                  }
                  return null;
                },
              ),
              if (!widget.payments) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: signature,
                  decoration: const InputDecoration(
                    labelText: 'Signature (facultatif)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Visible par les membres'),
                value: published,
                onChanged: (v) => setState(() => published = v),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: saving ? null : save,
                    child: Text(saving ? 'Enregistrement…' : 'Enregistrer'),
                  ),
                  if (editing != null)
                    TextButton(onPressed: clear, child: const Text('Annuler')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.payments ? 'Liens de paiement' : 'Messages',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Aucun élément pour le moment.'),
          )
        else
          ...items.map(
            (item) => Card(
              child: ListTile(
                title: Text(item['title'] as String? ?? ''),
                subtitle: Text(
                  item['published'] == true ? 'Publié' : 'Brouillon',
                ),
                onTap: () {
                  title.text = item['title'] as String? ?? '';
                  content.text =
                      item[widget.payments ? 'url' : 'content'] as String? ??
                      '';
                  signature.text = item['signature'] as String? ?? '';
                  setState(() {
                    editing = item['id'] as int;
                    published = item['published'] == true;
                  });
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => remove(item),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
