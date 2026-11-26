import 'package:flutter/material.dart';
import '../../data/admin_api.dart';

class MembersTrackingForm extends StatefulWidget {
  final AdminApi? api;
  const MembersTrackingForm({super.key, this.api});
  @override
  State<MembersTrackingForm> createState() => _MembersTrackingFormState();
}

class _MembersTrackingFormState extends State<MembersTrackingForm> {
  late final api = widget.api ?? AdminApi();
  final form = GlobalKey<FormState>();
  final first = TextEditingController(),
      last = TextEditingController(),
      email = TextEditingController();
  List<Map<String, dynamic>> members = [];
  String role = 'MEMBER';
  String? error;
  bool loading = true, saving = false;
  static const path = '/api/admin-association/members';
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final value = await api.list(path);
      if (mounted) setState(() => members = value);
    } catch (_) {
      if (mounted) setState(() => error = 'Impossible de charger les membres.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> create() async {
    if (!form.currentState!.validate() || saving) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final response = await api.createMember({
        'email': email.text.trim(),
        'firstName': first.text.trim(),
        'lastName': last.text.trim(),
        'role': role,
      });
      if (!mounted) return;
      final message = response['message'] as String? ?? 'Membre ajouté.';
      first.clear();
      last.clear();
      email.clear();
      await load();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Impossible d’ajouter ce membre.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> changeRole(Map<String, dynamic> member, String value) async {
    try {
      await api.setMemberRole(member['membershipId'] as int, value);
      await load();
    } catch (_) {
      if (mounted) setState(() => error = 'Impossible de modifier le rôle.');
    }
  }

  Future<void> remove(Map<String, dynamic> member) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Retirer ce membre ?'),
        content: Text(member['email'] as String? ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await api.delete(path, member['membershipId'] as int);
      await load();
    } catch (_) {
      if (mounted) setState(() => error = 'Impossible de retirer ce membre.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Suivi des membres')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),
        Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ajouter un membre',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: first,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Prénom obligatoire.'
                    : null,
              ),
              TextFormField(
                controller: last,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nom obligatoire.' : null,
              ),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    v == null ||
                        !RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(v.trim())
                    ? 'E-mail invalide.'
                    : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(value: 'MEMBER', child: Text('Membre')),
                  DropdownMenuItem(
                    value: 'ADMIN',
                    child: Text('Administrateur'),
                  ),
                ],
                onChanged: (v) => setState(() => role = v!),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: saving ? null : create,
                child: Text(saving ? 'Enregistrement…' : 'Ajouter'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Membres', style: Theme.of(context).textTheme.titleLarge),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (members.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Aucun membre.'),
          )
        else
          ...members.map(
            (m) => Card(
              child: ExpansionTile(
                title: Text(
                  '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim(),
                ),
                subtitle: Text(m['email'] as String? ?? ''),
                children: [
                  ListTile(
                    title: const Text('Rôle'),
                    trailing: DropdownButton<String>(
                      value: m['role'] == 'ADMIN' ? 'ADMIN' : 'MEMBER',
                      items: const [
                        DropdownMenuItem(
                          value: 'MEMBER',
                          child: Text('Membre'),
                        ),
                        DropdownMenuItem(
                          value: 'ADMIN',
                          child: Text('Administrateur'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null && v != m['role']) changeRole(m, v);
                      },
                    ),
                  ),
                  if (m['membershipDues'] is Map)
                    ListTile(
                      title: const Text('Adhésion'),
                      subtitle: Text(
                        'Statut : ${(m['membershipDues'] as Map)['status'] ?? 'Non renseigné'}',
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => remove(m),
                    icon: const Icon(Icons.person_remove),
                    label: const Text('Retirer le membre'),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
