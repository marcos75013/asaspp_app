import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'bo_widgets.dart';

class BoAssociation extends StatelessWidget {
  const BoAssociation({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Mon association',
    load: (api) async => [
      Map<String, dynamic>.from(
        await api.request('/api/admin-association/association'),
      ),
    ],
    tile: (context, api, a, reload) => BoCard(
      title: label(a, 'name'),
      subtitle: '${label(a, 'activityName')} · ${label(a, 'code')}',
      children: [
        if (a['logoUrl'] != null)
          Image.network(
            api.imageUrl(label(a, 'logoUrl')),
            height: 100,
            errorBuilder: (_, e, s) => const Icon(Icons.image_not_supported),
          ),
        Wrap(
          children: [
            BoAction('Modifier le nom', () async {
              if (await boOpen<bool>(
                    context,
                    BoForm(
                      title: 'Mon association',
                      fields: const [BoField('name', 'Nom', required: true)],
                      initial: {'name': a['name']},
                      save: (v) async {
                        await api.request(
                          '/api/admin-association/association',
                          method: 'PUT',
                          data: v,
                        );
                      },
                    ),
                  ) ==
                  true)
                await reload();
            }),
            BoAction('Changer le logo', () async {
              final files = await pickBoFiles(images: true);
              if (files.isEmpty) return;
              await api.request(
                '/api/admin-association/association/logo',
                method: 'POST',
                data: FormData.fromMap({'file': files.single}),
                responseType: ResponseType.plain,
              );
              await reload();
            }),
          ],
        ),
      ],
    ),
  );
}

class BoMessages extends StatelessWidget {
  const BoMessages({super.key});
  Future<void> _edit(
    BuildContext context,
    ClubApi api,
    Future<void> Function() reload, [
    Json? row,
  ]) async {
    if (await boOpen<bool>(
          context,
          BoForm(
            title: row == null ? 'Écrire un message' : 'Modifier le message',
            fields: const [
              BoField('title', 'Titre', required: true),
              BoField('content', 'Message', kind: 'multiline', required: true),
              BoField('published', 'Publié', kind: 'bool'),
            ],
            initial: row ?? {'published': false},
            save: (v) async {
              await api.request(
                '/api/admin-association/messages${row == null ? '' : '/${row['id']}'}',
                method: row == null ? 'POST' : 'PUT',
                data: v,
              );
            },
          ),
        ) ==
        true)
      await reload();
  }

  @override
  Widget build(BuildContext context) => BoList(
    title: 'Messages de l’association',
    load: (api) => api.list('/api/admin-association/messages'),
    add: (c, a, r) => _edit(c, a, r),
    tile: (c, a, m, r) => BoCard(
      title: label(m, 'title'),
      subtitle:
          '${m['published'] == true ? 'Publié' : 'Brouillon'}\n${label(m, 'content')}',
      children: [
        Wrap(
          children: [
            BoAction('Modifier', () => _edit(c, a, r, m)),
            BoAction(
              'Supprimer',
              () => boDelete(
                c,
                a,
                '/api/admin-association/messages/${m['id']}',
                r,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class BoDocuments extends StatelessWidget {
  const BoDocuments({super.key});
  Future<void> _edit(
    BuildContext context,
    ClubApi api,
    Future<void> Function() reload, [
    Json? row,
  ]) async {
    final categories = await api.list('/api/documents/categories');
    if (!context.mounted) return;
    final ok = await boOpen<bool>(
      context,
      BoForm(
        title: row == null ? 'Ajouter un document' : 'Modifier le document',
        help: row == null
            ? 'Sélectionnez le fichier après avoir renseigné ses informations.'
            : null,
        fields: [
          const BoField('title', 'Titre', required: true),
          const BoField('description', 'Description', kind: 'multiline'),
          BoField(
            'categoryId',
            'Catégorie',
            options: {
              for (final c in categories) '${c['id']}': label(c, 'name'),
            },
          ),
          const BoField('published', 'Publié', kind: 'bool'),
        ],
        initial: row ?? {'published': false},
        save: (v) async {
          v['categoryId'] = int.tryParse('${v['categoryId']}');
          if (row == null) {
            final files = await pickBoFiles(maxMB: 20);
            if (files.isEmpty) throw StateError('Choisissez un fichier.');
            await api.request(
              '/api/documents',
              method: 'POST',
              data: FormData.fromMap({...v, 'file': files.single}),
            );
          } else {
            await api.request(
              '/api/documents/${row['id']}',
              method: 'PUT',
              data: v,
            );
          }
        },
      ),
    );
    if (ok == true) await reload();
  }

  @override
  Widget build(BuildContext context) => BoList(
    title: 'Documents de l’association',
    load: (api) => api.list('/api/documents', query: {'includeDrafts': true}),
    actions: [
      IconButton(
        tooltip: 'Catégories',
        onPressed: () => boOpen(context, const BoDocumentCategories()),
        icon: const Icon(Icons.category_outlined),
      ),
    ],
    add: (c, a, r) => _edit(c, a, r),
    tile: (c, a, d, r) => BoCard(
      title: label(d, 'title'),
      subtitle:
          '${d['published'] == true ? 'Publié' : 'Brouillon'} · ${label(d, 'categoryName', 'Sans catégorie')}\n${label(d, 'description')}',
      children: [
        Wrap(
          children: [
            BoAction(
              'Télécharger',
              () => boDownload(c, a, '/api/documents/${d['id']}/download', d),
            ),
            BoAction('Modifier', () => _edit(c, a, r, d)),
            BoAction(
              'Supprimer',
              () => boDelete(c, a, '/api/documents/${d['id']}', r),
            ),
          ],
        ),
      ],
    ),
  );
}

class BoDocumentCategories extends StatelessWidget {
  const BoDocumentCategories({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Catégories de documents',
    load: (api) => api.list('/api/documents/categories'),
    add: (c, a, r) async {
      if (await boOpen<bool>(
            c,
            BoForm(
              title: 'Nouvelle catégorie',
              fields: const [BoField('name', 'Nom', required: true)],
              save: (v) async {
                await a.request(
                  '/api/documents/categories',
                  method: 'POST',
                  query: v,
                );
              },
            ),
          ) ==
          true)
        await r();
    },
    tile: (c, a, d, r) => BoCard(
      title: label(d, 'name'),
      children: [
        BoAction(
          'Supprimer',
          () => boDelete(c, a, '/api/documents/categories/${d['id']}', r),
        ),
      ],
    ),
  );
}

Future<bool> editBoAlbum(
  BuildContext context,
  ClubApi api, [
  Json? row,
]) async =>
    await boOpen<bool>(
      context,
      BoForm(
        title: row == null ? 'Créer un album' : 'Modifier l’album',
        fields: const [
          BoField('title', 'Titre', required: true),
          BoField('description', 'Description', kind: 'multiline'),
          BoField('published', 'Publié', kind: 'bool'),
        ],
        initial: row ?? {'published': false},
        save: (v) async {
          await api.request(
            '/api/gallery${row == null ? '' : '/${row['id']}'}',
            method: row == null ? 'POST' : 'PUT',
            query: {
              'title': v['title'],
              'description': v['description'] ?? '',
              'published': v['published'] == true,
            },
          );
        },
      ),
    ) ==
    true;

class BoAlbums extends StatelessWidget {
  const BoAlbums({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Albums de l’association',
    load: (api) => api.list('/api/gallery', query: {'includeDrafts': true}),
    add: (c, a, r) async {
      if (await editBoAlbum(c, a)) await r();
    },
    tile: (c, a, d, r) => BoCard(
      title: label(d, 'title'),
      subtitle:
          '${d['published'] == true ? 'Publié' : 'Brouillon'} · ${records(d['photos']).length} photo(s)\n${label(d, 'description')}',
      children: [
        Wrap(
          children: [
            BoAction('Modifier', () async {
              if (await editBoAlbum(c, a, d)) await r();
            }),
            BoAction('Gérer les photos', () async {
              await boOpen(c, BoAlbumPhotos(albumId: d['id'] as int));
              await r();
            }),
            BoAction(
              'Supprimer',
              () => boDelete(c, a, '/api/gallery/${d['id']}', r),
            ),
          ],
        ),
      ],
    ),
  );
}

class BoAlbumPhotos extends StatelessWidget {
  final int albumId;
  const BoAlbumPhotos({super.key, required this.albumId});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Photos de l’album',
    load: (api) async {
      final albums = await api.list(
        '/api/gallery',
        query: {'includeDrafts': true},
      );
      final album = albums.firstWhere((a) => a['id'] == albumId);
      return records(
        album['photos'],
      ).map((p) => {...p, 'cover': p['id'] == album['coverPhotoId']}).toList();
    },
    add: (c, a, r) async {
      final files = await pickBoFiles(images: true, multiple: true);
      if (files.isEmpty) return;
      await a.request(
        '/api/gallery/$albumId/photos',
        method: 'POST',
        data: FormData.fromMap({'files': files}),
      );
      await r();
    },
    tile: (c, a, p, r) => BoCard(
      title: label(p, 'originalFilename'),
      subtitle: p['cover'] == true ? 'Couverture' : null,
      children: [
        Image.network(
          a.imageUrl(label(p, 'url')),
          height: 180,
          errorBuilder: (_, e, s) => const Icon(Icons.broken_image),
        ),
        Wrap(
          children: [
            BoAction('Définir comme couverture', () async {
              await a.request(
                '/api/gallery/$albumId/cover/${p['id']}',
                method: 'PATCH',
              );
              await r();
            }),
            BoAction(
              'Supprimer',
              () =>
                  boDelete(c, a, '/api/gallery/$albumId/photos/${p['id']}', r),
            ),
          ],
        ),
      ],
    ),
  );
}

class BoMarketplace extends StatelessWidget {
  const BoMarketplace({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Gestion des annonces',
    load: (a) => a.list('/api/marketplace', query: {'includeInactive': true}),
    tile: (c, a, d, r) => BoCard(
      title: label(d, 'title'),
      subtitle:
          '${label(d, 'authorFirstName')} ${label(d, 'authorLastName')} · ${d['active'] == true ? 'Visible' : 'Masquée'}\n${boLabel(d['status'])}\n${label(d, 'description')}',
      children: [
        Wrap(
          children: [
            BoAction(d['active'] == true ? 'Masquer' : 'Réactiver', () async {
              await a.request(
                '/api/marketplace/${d['id']}/active',
                method: 'PATCH',
                query: {'active': d['active'] != true},
              );
              await r();
            }),
            BoAction('Changer le statut', () async {
              if (await boOpen<bool>(
                    c,
                    BoForm(
                      title: 'Statut de l’annonce',
                      fields: [
                        BoField(
                          'status',
                          'Statut',
                          required: true,
                          options: {
                            'ACTIVE': 'Disponible',
                            'SOLD': 'Vendue',
                            'CLOSED': 'Clôturée',
                          },
                        ),
                      ],
                      initial: {'status': d['status']},
                      save: (v) async {
                        await a.request(
                          '/api/marketplace/${d['id']}/status',
                          method: 'PATCH',
                          query: v,
                        );
                      },
                    ),
                  ) ==
                  true)
                await r();
            }),
            BoAction(
              'Supprimer',
              () => boDelete(c, a, '/api/marketplace/${d['id']}', r),
            ),
          ],
        ),
      ],
    ),
  );
}
