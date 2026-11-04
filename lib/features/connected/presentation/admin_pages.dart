import 'package:flutter/material.dart';
import '../data/club_api.dart';
import 'club_widgets.dart';
import 'collection_page.dart';

/// Only linked for ADMIN memberships. The server independently enforces access.
class ConnectedAdmin extends StatelessWidget {
  final ClubApi api;
  final List<String> modules;
  const ConnectedAdmin({super.key, required this.api, required this.modules});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Espace administrateur')),
    body: PageBody(
      children: [
        const Heading(
          'Faire vivre le collectif',
          'Retrouvez les informations de gestion de votre association.',
        ),
        _tile(
          context,
          'Les membres',
          'Identités, profils et cotisations',
          Icons.people_outline,
          MembersPage(api: api),
        ),
        _tile(
          context,
          'Documents à suivre',
          'Alertes sur les justificatifs',
          Icons.fact_check_outlined,
          ComplianceAlerts(api: api),
        ),
        if (modules.contains('CLUB_COMMUNICATION'))
          _tile(
            context,
            'Messages du club',
            'Préparer et publier les informations',
            Icons.campaign_outlined,
            AdminMessages(api: api),
          ),
        if (modules.contains('EVENTS'))
          _tile(
            context,
            'Présences',
            'Retrouver le suivi des membres',
            Icons.how_to_reg_outlined,
            AttendanceStats(api: api),
          ),
      ],
    ),
  );
  Widget _tile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget page,
  ) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(20),
      leading: Icon(icon, color: teal),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => openPage(context, page),
    ),
  );
}

class MembersPage extends StatelessWidget {
  final ClubApi api;
  const MembersPage({super.key, required this.api});
  @override
  Widget build(BuildContext context) => CollectionPage(
    api: api,
    path: '/api/admin-association/members',
    title: 'Les membres',
    subtitle: 'Les personnes qui font votre association.',
    itemBuilder: (context, member, refresh) => Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: mint,
          child: Icon(Icons.person_outline, color: teal),
        ),
        title: Text(
          '${label(member, 'firstName')} ${label(member, 'lastName')}',
        ),
        subtitle: Text(label(member, 'email')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openPage(context, MemberDetails(api: api, member: member)),
      ),
    ),
  );
}

class MemberDetails extends StatelessWidget {
  final ClubApi api;
  final Json member;
  const MemberDetails({super.key, required this.api, required this.member});
  @override
  Widget build(BuildContext context) {
    final sport = Map<String, dynamic>.from(
      member['sportProfile'] as Map? ?? {},
    );
    final dues = Map<String, dynamic>.from(
      member['membershipDues'] as Map? ?? {},
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Fiche membre')),
      body: PageBody(
        children: [
          Heading(
            '${label(member, 'firstName')} ${label(member, 'lastName')}',
            label(member, 'email'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Tag(label(member, 'role')),
          ),
          const SizedBox(height: 20),
          if (sport.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profil d’activité',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...{
                          'divingLevel': 'Niveau',
                          'licenseNumber': 'Licence',
                          'medicalCertificateExpiresOn':
                              'Échéance du certificat',
                          'footballTeam': 'Équipe',
                          'footballCategory': 'Catégorie',
                          'footballPosition': 'Poste',
                          'footballJerseyNumber': 'Numéro de maillot',
                        }.entries
                        .where((entry) => sport[entry.key] != null)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('${entry.value} : ${sport[entry.key]}'),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          if (dues.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cotisation',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Saison : ${label(dues, 'season', 'Non renseignée')}'),
                    Text('Statut : ${label(dues, 'status', 'Non renseigné')}'),
                    Text(
                      'Versé : ${label(dues, 'paidAmount', '0')} € / ${label(dues, 'amount', '0')} €',
                    ),
                  ],
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => openPage(
              context,
              MemberDocuments(
                api: api,
                membershipId: member['membershipId'] as int,
              ),
            ),
            icon: const Icon(Icons.folder_outlined),
            label: const Text('Consulter les justificatifs'),
          ),
        ],
      ),
    );
  }
}

class MemberDocuments extends StatelessWidget {
  final ClubApi api;
  final int membershipId;
  const MemberDocuments({
    super.key,
    required this.api,
    required this.membershipId,
  });
  @override
  Widget build(BuildContext context) => CollectionPage(
    api: api,
    path: '/api/admin-association/members/$membershipId/compliance-documents',
    title: 'Justificatifs',
    subtitle: 'Les documents déposés dans le dossier du membre.',
    itemBuilder: (context, doc, refresh) => Card(
      child: ListTile(
        leading: Icon(
          doc['verified'] == true
              ? Icons.verified_outlined
              : Icons.pending_outlined,
          color: teal,
        ),
        title: Text(label(doc, 'originalFilename', label(doc, 'type'))),
        subtitle: Text(
          '${label(doc, 'type')} · ${doc['verified'] == true ? 'Vérifié' : 'À vérifier'}'
          '${doc['expiresOn'] == null ? '' : '\nÉchéance : ${doc['expiresOn']}'}',
        ),
      ),
    ),
  );
}

class ComplianceAlerts extends StatelessWidget {
  final ClubApi api;
  const ComplianceAlerts({super.key, required this.api});
  @override
  Widget build(BuildContext context) => CollectionPage(
    api: api,
    path: '/api/admin-association/members/compliance-documents/alerts',
    title: 'Documents à suivre',
    subtitle: 'Les échéances à garder en tête.',
    emptyMessage: 'Aucune alerte sur les justificatifs.',
    itemBuilder: (context, alert, refresh) => Card(
      child: ListTile(
        leading: const Icon(Icons.notification_important_outlined, color: teal),
        title: Text(label(alert, 'memberName')),
        subtitle: Text('${label(alert, 'type')} · ${label(alert, 'status')}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openPage(
          context,
          MemberDocuments(api: api, membershipId: alert['membershipId'] as int),
        ),
      ),
    ),
  );
}

class AttendanceStats extends StatelessWidget {
  final ClubApi api;
  const AttendanceStats({super.key, required this.api});
  @override
  Widget build(BuildContext context) => CollectionPage(
    api: api,
    path: '/api/events/attendance/stats',
    title: 'Les présences',
    subtitle: 'Le suivi des rendez-vous de votre association.',
    itemBuilder: (context, row, refresh) => Card(
      child: ListTile(
        title: Text('${label(row, 'firstName')} ${label(row, 'lastName')}'),
        subtitle: Text(
          '${label(row, 'presentCount', '0')} présence(s) · ${label(row, 'absentCount', '0')} absence(s)',
        ),
        leading: const Icon(Icons.insights_outlined, color: teal),
      ),
    ),
  );
}

class AdminMessages extends StatefulWidget {
  final ClubApi api;
  const AdminMessages({super.key, required this.api});
  @override
  State<AdminMessages> createState() => _AdminMessagesState();
}

class _AdminMessagesState extends State<AdminMessages> {
  int _revision = 0;
  Future<void> _edit([Json? message]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MessageForm(api: widget.api, message: message),
      ),
    );
    if (saved == true && mounted) setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) => CollectionPage(
    key: ValueKey(_revision),
    api: widget.api,
    path: '/api/admin-association/messages',
    title: 'Messages du club',
    subtitle: 'Les nouvelles qui nous rapprochent.',
    action: FloatingActionButton.extended(
      onPressed: _edit,
      icon: const Icon(Icons.edit_outlined),
      label: const Text('Écrire un message'),
    ),
    itemBuilder: (context, message, refresh) => Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tag(message['published'] == true ? 'Publié' : 'Brouillon'),
            const SizedBox(height: 12),
            Text(
              label(message, 'title'),
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(label(message, 'content')),
            TextButton(
              onPressed: () => _edit(message),
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    ),
  );
}

class MessageForm extends StatefulWidget {
  final ClubApi api;
  final Json? message;
  const MessageForm({super.key, required this.api, this.message});
  @override
  State<MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.message?['title']);
  late final _content = TextEditingController(text: widget.message?['content']);
  late bool _published = widget.message?['published'] == true;
  bool _busy = false;
  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Message du club')),
    body: Form(
      key: _form,
      child: PageBody(
        children: [
          const Heading(
            'Un mot pour le collectif',
            'Partagez une information avec votre association.',
          ),
          TextFormField(
            controller: _title,
            maxLength: 255,
            decoration: const InputDecoration(labelText: 'Titre'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Indiquez un titre.'
                : null,
          ),
          TextFormField(
            controller: _content,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(labelText: 'Votre message'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Écrivez votre message.'
                : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Publier le message'),
            subtitle: const Text('Désactivé : enregistrer comme brouillon.'),
            value: _published,
            onChanged: _busy
                ? null
                : (value) => setState(() => _published = value),
          ),
          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    if (!_form.currentState!.validate()) return;
                    setState(() => _busy = true);
                    await runAction(context, () async {
                      await widget.api.request(
                        '/api/admin-association/messages${widget.message == null ? '' : '/${widget.message!['id']}'}',
                        method: widget.message == null ? 'POST' : 'PUT',
                        data: {
                          'title': _title.text.trim(),
                          'content': _content.text.trim(),
                          'published': _published,
                        },
                      );
                      if (context.mounted) Navigator.pop(context, true);
                    });
                    if (mounted) setState(() => _busy = false);
                  },
            child: Text(
              _busy
                  ? 'Enregistrement…'
                  : _published
                  ? 'Publier le message'
                  : 'Enregistrer le brouillon',
            ),
          ),
        ],
      ),
    ),
  );
}
