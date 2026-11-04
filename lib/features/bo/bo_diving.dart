import 'package:flutter/material.dart';
import 'bo_widgets.dart';

const _base = '/api/diving/trips';

class BoDiving extends StatelessWidget {
  const BoDiving({super.key});
  Future<void> _edit(
    BuildContext context,
    ClubApi api,
    Future<void> Function() reload, [
    Json? plan,
  ]) async {
    final events = await allBoEvents(api);
    final divers = await api.list('$_base/readiness');
    if (!context.mounted) return;
    final ok = await boOpen<bool>(
      context,
      BoForm(
        title: plan == null ? 'Préparer une plongée' : 'Fiche de plongée',
        initial: plan ?? {'status': 'DRAFT'},
        fields: [
          BoField(
            'eventId',
            'Événement',
            required: true,
            options: {
              for (final e in events)
                '${e['id']}': '${label(e, 'title')} · ${label(e, 'startDate')}',
            },
          ),
          const BoField('siteName', 'Site', required: true),
          const BoField(
            'plannedDepthMeters',
            'Profondeur prévue (m)',
            kind: 'integer',
            min: 1,
            max: 120,
          ),
          BoField(
            'diveDirectorMembershipId',
            'Directeur de plongée',
            options: {
              for (final d in divers) '${d['membershipId']}': label(d, 'name'),
            },
          ),
          BoField(
            'status',
            'Statut',
            required: true,
            options: choices(['DRAFT', 'READY', 'COMPLETED', 'CANCELLED']),
          ),
          const BoField(
            'safetyNotes',
            'Consignes de sécurité',
            kind: 'multiline',
          ),
        ],
        save: (v) async {
          for (final key in ['eventId', 'diveDirectorMembershipId'])
            v[key] = int.tryParse('${v[key]}');
          await api.request(
            '$_base${plan == null ? '' : '/${plan['id']}'}',
            method: plan == null ? 'POST' : 'PUT',
            data: v,
          );
        },
      ),
    );
    if (ok == true) await reload();
  }

  @override
  Widget build(BuildContext context) => BoList(
    title: 'Préparation des plongées',
    load: (a) => a.list(_base),
    actions: [
      IconButton(
        tooltip: 'Aptitude administrative des plongeurs',
        onPressed: () => boOpen(context, const BoDiverReadiness()),
        icon: const Icon(Icons.fact_check_outlined),
      ),
    ],
    add: (c, a, r) => _edit(c, a, r),
    tile: (c, a, p, r) => BoCard(
      title: label(p, 'eventTitle'),
      subtitle:
          '${label(p, 'siteName')} · ${boLabel(p['status'])}\nProfondeur : ${display(p['plannedDepthMeters'])} m\nDirecteur : ${display(p['diveDirectorName'])}\n${label(p, 'safetyNotes')}',
      children: [
        Wrap(
          children: [
            BoAction('Modifier', () => _edit(c, a, r, p)),
            BoAction('Palanquées', () async {
              await boOpen(c, BoDivingGroups(planId: p['id'] as int));
            }),
            BoAction('Supprimer', () => boDelete(c, a, '$_base/${p['id']}', r)),
          ],
        ),
      ],
    ),
  );
}

class BoDiverReadiness extends StatelessWidget {
  const BoDiverReadiness({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Dossiers des plongeurs',
    load: (a) => a.list('$_base/readiness'),
    tile: (c, a, d, r) => BoCard(
      title: label(d, 'name'),
      subtitle:
          '${display(d['divingLevel'])} · ${d['ready'] == true ? 'Dossier complet' : 'Dossier à compléter'}\nLicence : ${display(d['licenseNumber'])}\nCertificat : ${display(d['medicalCertificateExpiresOn'])}\n${(d['alerts'] as List? ?? []).join('\n')}',
    ),
  );
}

class BoDivingGroups extends StatelessWidget {
  final int planId;
  const BoDivingGroups({super.key, required this.planId});
  Future<void> _edit(
    BuildContext context,
    ClubApi api,
    Future<void> Function() reload, [
    Json? group,
  ]) async {
    final divers = await api.list('$_base/$planId/eligible-divers');
    if (!context.mounted) return;
    final ok = await boOpen<bool>(
      context,
      BoForm(
        title: 'Palanquée',
        initial: {
          ...?group,
          'memberMembershipIds': records(
            group?['members'],
          ).map((m) => '${m['membershipId']}').toList(),
        },
        fields: [
          const BoField('name', 'Nom', required: true),
          const BoField(
            'plannedDepthMeters',
            'Profondeur prévue (m)',
            kind: 'integer',
            min: 1,
            max: 120,
          ),
          BoField(
            'guideMembershipId',
            'Guide',
            options: {
              for (final d in divers) '${d['membershipId']}': label(d, 'name'),
            },
          ),
          BoField(
            'memberMembershipIds',
            'Plongeurs inscrits',
            kind: 'multi',
            options: {
              for (final d in divers)
                '${d['membershipId']}':
                    '${label(d, 'name')} · ${d['ready'] == true ? 'Dossier complet' : 'À vérifier'}',
            },
          ),
        ],
        validate: (v) => (v['memberMembershipIds'] as List? ?? []).isEmpty
            ? 'Sélectionnez au moins un plongeur.'
            : null,
        save: (v) async {
          v['guideMembershipId'] = int.tryParse('${v['guideMembershipId']}');
          v['memberMembershipIds'] = (v['memberMembershipIds'] as List)
              .map((id) => int.parse('$id'))
              .toList();
          await api.request(
            group == null
                ? '$_base/$planId/groups'
                : '$_base/groups/${group['id']}',
            method: group == null ? 'POST' : 'PUT',
            data: v,
          );
        },
      ),
    );
    if (ok == true) await reload();
  }

  @override
  Widget build(BuildContext context) => BoList(
    title: 'Palanquées',
    load: (a) => a.list('$_base/$planId/groups'),
    add: (c, a, r) => _edit(c, a, r),
    tile: (c, a, g, r) => BoCard(
      title: label(g, 'name'),
      subtitle:
          'Guide : ${display(g['guideName'])}\nProfondeur : ${display(g['plannedDepthMeters'])} m\n${records(g['members']).map((m) => '${label(m, 'name')} · ${display(m['level'])}\n${(m['alerts'] as List? ?? []).join(', ')}').join('\n')}',
      children: [
        Wrap(
          children: [
            BoAction('Modifier', () => _edit(c, a, r, g)),
            BoAction(
              'Supprimer',
              () => boDelete(c, a, '$_base/groups/${g['id']}', r),
            ),
          ],
        ),
      ],
    ),
  );
}
