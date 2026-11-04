import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'bo_widgets.dart';

class MemberListings extends StatelessWidget {
  const MemberListings({super.key});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Mes annonces',
    load: (a) => a.list('/api/marketplace', query: {'mine': true}),
    tile: (c, a, d, r) => BoCard(
      title: label(d, 'title'),
      subtitle:
          '${d['status'] == 'ACTIVE' ? 'Disponible' : boLabel(d['status'])}\n${label(d, 'description')}',
      children: [
        Wrap(
          children: [
            BoAction('Modifier', () async {
              final ok = await boOpen<bool>(
                c,
                BoForm(
                  title: 'Mon annonce',
                  fields: [
                    BoField(
                      'type',
                      'Type',
                      required: true,
                      options: const {
                        'SALE': 'Vente',
                        'GIFT': 'Don',
                        'WANTED': 'Recherche',
                      },
                    ),
                    const BoField('title', 'Titre', required: true),
                    const BoField(
                      'description',
                      'Description',
                      kind: 'multiline',
                      required: true,
                    ),
                    const BoField('price', 'Prix (€)', kind: 'number', min: 0),
                    const BoField('contactPhone', 'Téléphone'),
                  ],
                  initial: d,
                  validate: (v) => v['type'] == 'SALE' && v['price'] == null
                      ? 'Indiquez un prix.'
                      : null,
                  save: (v) async {
                    if (v['type'] != 'SALE') v['price'] = null;
                    await a.request(
                      '/api/marketplace/${d['id']}',
                      method: 'PUT',
                      data: v,
                    );
                  },
                ),
              );
              if (ok == true) await r();
            }),
            BoAction('Statut', () async {
              if (await boOpen<bool>(
                    c,
                    BoForm(
                      title: 'Statut de mon annonce',
                      fields: [
                        BoField(
                          'status',
                          'Statut',
                          required: true,
                          options: const {
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
            BoAction('Photos', () async {
              await boOpen(c, MemberListingPhotos(listingId: d['id'] as int));
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

class MemberListingPhotos extends StatelessWidget {
  final int listingId;
  const MemberListingPhotos({super.key, required this.listingId});
  @override
  Widget build(BuildContext context) => BoList(
    title: 'Photos de mon annonce',
    load: (a) async =>
        records((await a.request('/api/marketplace/$listingId'))['images']),
    add: (c, a, r) async {
      final files = await pickBoFiles(images: true, multiple: true, maxMB: 5);
      if (files.isEmpty) return;
      final current = records(
        (await a.request('/api/marketplace/$listingId'))['images'],
      );
      if (current.length + files.length > 5)
        throw StateError('Une annonce accepte au maximum 5 photos.');
      await a.request(
        '/api/marketplace/$listingId/images',
        method: 'POST',
        data: FormData.fromMap({'files': files}),
      );
      await r();
    },
    tile: (c, a, p, r) => BoCard(
      title: label(p, 'originalFilename', 'Photo'),
      children: [
        Image.network(
          a.imageUrl(label(p, 'url')),
          height: 180,
          errorBuilder: (_, e, s) => const Icon(Icons.broken_image),
        ),
        BoAction(
          'Supprimer',
          () => boDelete(
            c,
            a,
            '/api/marketplace/$listingId/images/${p['id']}',
            r,
          ),
        ),
      ],
    ),
  );
}
