import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'bo_widgets.dart';

const memberBase = '/api/admin-association/members';

class BoMembers extends StatelessWidget {
  const BoMembers({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Suivi des membres',
    load: (api) => api.list(memberBase),
    add: (context, api, reload) async {
      Json? result;
      final saved = await boOpen<bool>(
        context,
        BoForm(
          title: 'Ajouter un membre',
          help:
              'Le serveur peut envoyer une invitation à cette adresse. Le résultat de l’envoi sera indiqué après l’enregistrement.',
          fields: [
            const BoField('firstName', 'Prénom', required: true),
            const BoField('lastName', 'Nom', required: true),
            const BoField('email', 'Email', kind: 'email', required: true),
            BoField(
              'role',
              'Rôle',
              required: true,
              options: choices(['MEMBER', 'ADMIN']),
            ),
          ],
          initial: const {'role': 'MEMBER'},
          save: (v) async {
            result = Map<String, dynamic>.from(
              await api.request(memberBase, method: 'POST', data: v),
            );
          },
        ),
      );
      if (saved == true) {
        await reload();
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                label(
                  result ?? {},
                  'message',
                  result?['invitationEmailSent'] == true
                      ? 'Membre ajouté, invitation envoyée.'
                      : 'Membre ajouté. Invitation non envoyée.',
                ),
              ),
            ),
          );
      }
    },
    tile: (context, api, m, reload) => BoCard(
      title: person(m),
      subtitle:
          '${label(m, 'email')} · ${boLabel(m['role'])}\nCotisation : ${boLabel((m['membershipDues'] as Map?)?['status'])}',
      children: [
        Wrap(
          children: [
            BoAction('Consulter le dossier', () async {
              await boOpen(context, BoMemberDetail(api: api, member: m));
              await reload();
            }),
          ],
        ),
      ],
    ),
  );
}

class BoMemberDetail extends StatefulWidget {
  final ClubApi api;
  final Json member;
  const BoMemberDetail({super.key, required this.api, required this.member});
  @override
  State<BoMemberDetail> createState() => _BoMemberDetailState();
}

class _BoMemberDetailState extends State<BoMemberDetail> {
  late Json _member = Map.of(widget.member);
  Future<void> _refresh() async {
    final members = await widget.api.list(memberBase);
    final m = members
        .where((m) => m['membershipId'] == _member['membershipId'])
        .firstOrNull;
    if (m != null && mounted) setState(() => _member = m);
  }

  Future<void> _edit(
    String title,
    String suffix,
    List<BoField> fields,
    Json initial,
  ) async {
    final saved = await boOpen<bool>(
      context,
      BoForm(
        title: title,
        fields: fields,
        initial: initial,
        save: (v) async {
          await widget.api.request(
            '$memberBase/${_member['membershipId']}/$suffix',
            method: 'PUT',
            data: v,
          );
        },
      ),
    );
    if (saved == true) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final sport = Map<String, dynamic>.from(
      _member['sportProfile'] as Map? ?? {},
    );
    final dues = Map<String, dynamic>.from(
      _member['membershipDues'] as Map? ?? {},
    );
    final diving = sport['activityCode'] == 'DIVING';
    return Scaffold(
      appBar: AppBar(title: Text(person(_member))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          BoCard(
            title: 'Identité et rôle',
            subtitle: '${label(_member, 'email')}\n${boLabel(_member['role'])}',
            children: [
              BoAction(
                'Modifier le rôle',
                () => _edit(
                  'Rôle du membre',
                  'role',
                  [
                    BoField(
                      'role',
                      'Rôle',
                      required: true,
                      options: choices(['MEMBER', 'ADMIN']),
                    ),
                  ],
                  {'role': _member['role']},
                ),
              ),
            ],
          ),
          BoCard(
            title: 'Profil sportif',
            subtitle: [
              if (diving) 'Niveau : ${display(sport['divingLevel'])}',
              if (diving)
                'Qualifications : ${display((sport['divingQualifications'] as List?)?.join(', '))}',
              'Licence : ${display(sport['licenseNumber'])}',
              'Certificat médical : ${display(sport['medicalCertificateExpiresOn'])}',
              if (!diving) 'Équipe : ${display(sport['footballTeam'])}',
              if (!diving) 'Catégorie : ${display(sport['footballCategory'])}',
              if (!diving) 'Poste : ${display(sport['footballPosition'])}',
            ].join('\n'),
            children: [
              BoAction(
                'Modifier le profil',
                () => _edit(
                  'Profil sportif',
                  'sport-profile',
                  [
                    const BoField('firstName', 'Prénom', required: true),
                    const BoField('lastName', 'Nom', required: true),
                    if (diving) ...[
                      const BoField('divingLevel', 'Niveau de plongée'),
                      const BoField(
                        'divingQualifications',
                        'Qualifications (séparées par des virgules)',
                        kind: 'csv',
                      ),
                    ],
                    const BoField('licenseNumber', 'Numéro de licence'),
                    const BoField(
                      'medicalCertificateExpiresOn',
                      'Échéance du certificat',
                      kind: 'date',
                    ),
                    if (!diving) ...[
                      const BoField('footballTeam', 'Équipe'),
                      const BoField('footballCategory', 'Catégorie'),
                      const BoField('footballPosition', 'Poste'),
                      const BoField(
                        'footballJerseyNumber',
                        'Numéro de maillot',
                        kind: 'integer',
                        min: 1,
                        max: 99,
                      ),
                    ],
                  ],
                  {
                    ...sport,
                    'firstName': _member['firstName'],
                    'lastName': _member['lastName'],
                  },
                ),
              ),
            ],
          ),
          BoCard(
            title: 'Adhésion et cotisation',
            subtitle:
                'Saison : ${display(dues['season'])}\nStatut : ${boLabel(dues['status'])}\nMontant : ${display(dues['amount'])} €\nVersé : ${display(dues['paidAmount'])} €\nDate : ${display(dues['paidOn'])}\nMode : ${display(dues['paymentMethod'])}\n${dues['notes'] ?? ''}',
            children: [
              BoAction(
                'Modifier la cotisation',
                () => _edit('Cotisation', 'membership-dues', [
                  const BoField('season', 'Saison'),
                  BoField(
                    'status',
                    'Statut',
                    required: true,
                    options: choices([
                      'PENDING',
                      'ACTIVE',
                      'SUSPENDED',
                      'EXPIRED',
                    ]),
                  ),
                  const BoField(
                    'amount',
                    'Montant attendu (€)',
                    kind: 'number',
                    min: 0,
                  ),
                  const BoField(
                    'paidAmount',
                    'Montant payé (€)',
                    kind: 'number',
                    min: 0,
                  ),
                  const BoField('paidOn', 'Date du paiement', kind: 'date'),
                  const BoField('paymentMethod', 'Mode de paiement'),
                  const BoField('notes', 'Notes', kind: 'multiline'),
                ], dues),
              ),
            ],
          ),
          BoCard(
            title: 'Justificatifs',
            children: [
              BoAction('Consulter et gérer les documents', () async {
                await boOpen(
                  context,
                  BoMemberDocuments(
                    membershipId: _member['membershipId'] as int,
                  ),
                );
                await _refresh();
              }),
            ],
          ),
          BoAction('Retirer ce membre de l’association', () async {
            if (await boConfirm(
              context,
              'Retirer le membre ?',
              'Le membre perdra son accès à cette association.',
            )) {
              await widget.api.request(
                '$memberBase/${_member['membershipId']}',
                method: 'DELETE',
              );
              if (context.mounted) Navigator.pop(context);
            }
          }),
        ],
      ),
    );
  }
}

class BoMemberDocuments extends StatelessWidget {
  final int membershipId;
  const BoMemberDocuments({super.key, required this.membershipId});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Justificatifs du membre',
    load: (api) => api.list('$memberBase/$membershipId/compliance-documents'),
    add: (context, api, reload) async {
      final saved = await boOpen<bool>(
        context,
        BoForm(
          title: 'Ajouter un justificatif',
          help:
              'Après avoir renseigné le type et la date, sélectionnez le fichier à envoyer.',
          fields: [
            BoField(
              'type',
              'Type',
              required: true,
              options: choices(['MEDICAL_CERTIFICATE', 'LICENSE', 'OTHER']),
            ),
            const BoField('expiresOn', 'Date d’expiration', kind: 'date'),
          ],
          initial: const {'type': 'MEDICAL_CERTIFICATE'},
          save: (v) async {
            final files = await pickBoFiles();
            if (files.isEmpty) throw StateError('Aucun fichier sélectionné.');
            await api.request(
              '$memberBase/$membershipId/compliance-documents',
              method: 'POST',
              data: FormData.fromMap({...v, 'file': files.single}),
            );
          },
        ),
      );
      if (saved == true) await reload();
    },
    tile: (context, api, d, reload) => BoCard(
      title: label(d, 'originalFilename'),
      subtitle:
          '${boLabel(d['type'])} · ${d['verified'] == true ? 'Vérifié' : 'À vérifier'}\nÉchéance : ${display(d['expiresOn'])}',
      children: [
        Wrap(
          children: [
            BoAction(
              'Télécharger',
              () => boDownload(
                context,
                api,
                '$memberBase/compliance-documents/${d['id']}/download',
                d,
              ),
            ),
            BoAction(
              d['verified'] == true
                  ? 'Retirer la vérification'
                  : 'Marquer vérifié',
              () async {
                await api.request(
                  '$memberBase/compliance-documents/${d['id']}/verify',
                  method: 'PATCH',
                  query: {'verified': d['verified'] != true},
                );
                await reload();
              },
            ),
            BoAction(
              'Supprimer',
              () => boDelete(
                context,
                api,
                '$memberBase/compliance-documents/${d['id']}',
                reload,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class BoComplianceAlerts extends StatelessWidget {
  const BoComplianceAlerts({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Alertes justificatifs',
    load: (api) => api.list('$memberBase/compliance-documents/alerts'),
    tile: (context, api, a, reload) => BoCard(
      title: label(a, 'memberName'),
      subtitle:
          '${boLabel(a['type'])} · ${boLabel(a['status'])}\nÉchéance : ${display(a['expiresOn'])}',
      children: [
        BoAction('Ouvrir le dossier', () async {
          await boOpen(
            context,
            BoMemberDocuments(membershipId: a['membershipId'] as int),
          );
          await reload();
        }),
      ],
    ),
  );
}
