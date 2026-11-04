import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/club_api.dart';
import 'club_widgets.dart';
import 'collection_page.dart';

String listingType(dynamic type) => switch (type) {
  'SALE' => 'À vendre',
  'GIFT' => 'À donner',
  'WANTED' => 'Recherché',
  _ => 'Annonce',
};

class ConnectedMarketplace extends StatefulWidget {
  final ClubApi api;
  final bool embedded;
  const ConnectedMarketplace({
    super.key,
    required this.api,
    this.embedded = false,
  });
  @override
  State<ConnectedMarketplace> createState() => _ConnectedMarketplaceState();
}

class _ConnectedMarketplaceState extends State<ConnectedMarketplace> {
  int _revision = 0;
  String _filter = 'all';
  @override
  Widget build(BuildContext context) => CollectionPage(
    key: ValueKey('$_filter-$_revision'),
    api: widget.api,
    path: '/api/marketplace',
    embedded: widget.embedded,
    query: {'favoritesOnly': _filter == 'favorites', 'mine': _filter == 'mine'},
    title: 'Petites annonces',
    subtitle: 'Les annonces des membres de votre association.',
    action: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PopupMenuButton<String>(
          tooltip: 'Filtrer les annonces',
          initialValue: _filter,
          onSelected: (value) => setState(() => _filter = value),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'all', child: Text('Toutes les annonces')),
            PopupMenuItem(value: 'favorites', child: Text('Mes favoris')),
            PopupMenuItem(value: 'mine', child: Text('Mes annonces')),
          ],
          child: const Chip(avatar: Icon(Icons.tune), label: Text('Filtrer')),
        ),
        FloatingActionButton.extended(
          onPressed: () async {
            final saved = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => ListingForm(api: widget.api)),
            );
            if (saved == true && mounted) setState(() => _revision++);
          },
          icon: const Icon(Icons.add),
          label: const Text('Publier une annonce'),
        ),
      ],
    ),
    itemBuilder: (context, listing, refresh) {
      final images = records(listing['images'] ?? []);
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ListingDetails(api: widget.api, listing: listing),
              ),
            );
            if (context.mounted) refresh();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (images.isNotEmpty) ...[
                  ClubImage(widget.api.imageUrl(label(images.first, 'url'))),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Tag(listingType(listing['type'])),
                    const Spacer(),
                    if (listing['favorite'] == true)
                      const Icon(Icons.favorite, color: teal),
                    if (listing['price'] != null)
                      Text(
                        '${listing['price']} €',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  label(listing, 'title'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label(listing, 'description'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class ListingDetails extends StatefulWidget {
  final ClubApi api;
  final Json listing;
  const ListingDetails({super.key, required this.api, required this.listing});
  @override
  State<ListingDetails> createState() => _ListingDetailsState();
}

class _ListingDetailsState extends State<ListingDetails> {
  late Json _listing = widget.listing;
  bool _busy = false;
  Future<void> _action(Future<void> Function() action) async {
    setState(() => _busy = true);
    await runAction(context, action);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Petite annonce')),
    body: PageBody(
      children: [
        ...records(_listing['images'] ?? []).map(
          (image) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClubImage(
              widget.api.imageUrl(label(image, 'url')),
              height: 260,
            ),
          ),
        ),
        Heading(label(_listing, 'title'), listingType(_listing['type'])),
        if (_listing['price'] != null)
          Text(
            '${_listing['price']} €',
            style: const TextStyle(
              fontSize: 32,
              color: teal,
              fontWeight: FontWeight.w800,
            ),
          ),
        const SizedBox(height: 16),
        Text(
          label(_listing, 'description'),
          style: const TextStyle(height: 1.6),
        ),
        const SizedBox(height: 20),
        Text(
          'Publié par ${label(_listing, 'authorFirstName')} ${label(_listing, 'authorLastName')}',
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _busy
              ? null
              : () => _action(() async {
                  final result = await widget.api.request(
                    '/api/marketplace/${_listing['id']}/favorite',
                    method: 'POST',
                  );
                  if (mounted) {
                    setState(
                      () => _listing = Map<String, dynamic>.from(result as Map),
                    );
                  }
                }),
          icon: Icon(
            _listing['favorite'] == true
                ? Icons.favorite
                : Icons.favorite_border,
          ),
          label: Text(
            _listing['favorite'] == true
                ? 'Retirer des favoris'
                : 'Garder dans mes favoris',
          ),
        ),
        if (_listing['owner'] != true) ...[
          if (label(_listing, 'authorEmail').isNotEmpty)
            FilledButton.icon(
              onPressed: () => runAction(context, () async {
                final opened = await launchUrl(
                  Uri(
                    scheme: 'mailto',
                    path: label(_listing, 'authorEmail'),
                    query:
                        'subject=${Uri.encodeComponent(label(_listing, 'title'))}',
                  ),
                );
                if (!opened) {
                  throw StateError('Impossible d’ouvrir la messagerie.');
                }
              }),
              icon: const Icon(Icons.mail_outline),
              label: const Text('Contacter le membre'),
            ),
          if (label(_listing, 'contactPhone').isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => runAction(context, () async {
                if (!await launchUrl(
                  Uri(scheme: 'tel', path: label(_listing, 'contactPhone')),
                )) {
                  throw StateError('Téléphone indisponible.');
                }
              }),
              icon: const Icon(Icons.phone_outlined),
              label: Text(label(_listing, 'contactPhone')),
            ),
        ] else ...[
          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) =>
                            ListingForm(api: widget.api, listing: _listing),
                      ),
                    );
                    if (!context.mounted) return;
                    _action(() async {
                      final result = await widget.api.request(
                        '/api/marketplace/${_listing['id']}',
                      );
                      if (mounted) {
                        setState(
                          () => _listing = Map<String, dynamic>.from(
                            result as Map,
                          ),
                        );
                      }
                    });
                  },
            child: const Text('Modifier mon annonce'),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer cette annonce ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Conserver'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !context.mounted) return;
                    _action(() async {
                      await widget.api.request(
                        '/api/marketplace/${_listing['id']}',
                        method: 'DELETE',
                      );
                      if (context.mounted) Navigator.pop(context);
                    });
                  },
            child: const Text('Supprimer mon annonce'),
          ),
        ],
      ],
    ),
  );
}

class ListingForm extends StatefulWidget {
  final ClubApi api;
  final Json? listing;
  const ListingForm({super.key, required this.api, this.listing});
  @override
  State<ListingForm> createState() => _ListingFormState();
}

class _ListingFormState extends State<ListingForm> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.listing?['title']);
  late final _description = TextEditingController(
    text: widget.listing?['description'],
  );
  late final _price = TextEditingController(
    text: widget.listing?['price']?.toString(),
  );
  late final _phone = TextEditingController(
    text: widget.listing?['contactPhone'],
  );
  late String _type = widget.listing?['type'] ?? 'SALE';
  late int? _savedId = widget.listing?['id'] as int?;
  final List<XFile> _images = [];
  bool _busy = false;
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _phone.dispose();
    super.dispose();
  }

  String _imageType(XFile image) {
    final name = image.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    throw StateError('Utilisez des photos JPEG, PNG ou WebP.');
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await runAction(context, () async {
      final existing = records(widget.listing?['images'] ?? []).length;
      if (existing + _images.length > 5) {
        throw StateError('Une annonce peut contenir 5 photos maximum.');
      }
      for (final image in _images) {
        _imageType(image);
        if (await image.length() > 5 * 1024 * 1024) {
          throw StateError('Chaque photo doit peser 5 Mo maximum.');
        }
      }
      final saved = await widget.api.request(
        _savedId == null ? '/api/marketplace' : '/api/marketplace/$_savedId',
        method: _savedId == null ? 'POST' : 'PUT',
        data: {
          'type': _type,
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'price': _type == 'SALE'
              ? double.tryParse(_price.text.replaceAll(',', '.'))
              : null,
          'contactPhone': _phone.text.trim(),
        },
      );
      // Keep the created ID if an upload fails, so retry cannot duplicate the ad.
      _savedId = saved['id'] as int;
      while (_images.isNotEmpty) {
        final image = _images.first;
        await widget.api.request(
          '/api/marketplace/$_savedId/images',
          method: 'POST',
          data: FormData.fromMap({
            'files': [
              MultipartFile.fromBytes(
                await image.readAsBytes(),
                filename: image.name,
                contentType: DioMediaType.parse(_imageType(image)),
              ),
            ],
          }),
        );
        _images.removeAt(0);
      }
      if (mounted) Navigator.pop(context, true);
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mon annonce')),
    body: Form(
      key: _form,
      child: PageBody(
        children: [
          const Heading(
            'Faites circuler les bonnes choses.',
            'Une annonce visible par les membres de votre association.',
          ),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type d’annonce'),
            items: ['SALE', 'GIFT', 'WANTED']
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(listingType(type)),
                  ),
                )
                .toList(),
            onChanged: _busy ? null : (value) => setState(() => _type = value!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _title,
            maxLength: 150,
            decoration: const InputDecoration(labelText: 'Titre'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Ajoutez un titre.'
                : null,
          ),
          TextFormField(
            controller: _description,
            maxLength: 2000,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Décrivez votre annonce.'
                : null,
          ),
          if (_type == 'SALE')
            TextFormField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Prix en euros'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final price = double.tryParse(value.replaceAll(',', '.'));
                return price == null ||
                        price < 0 ||
                        !RegExp(r'^\d{1,8}([.,]\d{1,2})?$').hasMatch(value)
                    ? 'Indiquez un prix valide (2 décimales maximum).'
                    : null;
              },
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: 'Téléphone de contact (facultatif)',
            ),
          ),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => runAction(context, () async {
                    final images = await ImagePicker().pickMultiImage(
                      maxWidth: 1600,
                      imageQuality: 85,
                    );
                    if (mounted) setState(() => _images.addAll(images));
                  }),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Ajouter des photos'),
          ),
          ..._images.toList().map(
            (image) => ListTile(
              title: Text(image.name),
              trailing: IconButton(
                tooltip: 'Retirer la photo',
                onPressed: _busy
                    ? null
                    : () => setState(() => _images.remove(image)),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? 'Enregistrement…' : 'Enregistrer mon annonce'),
          ),
        ],
      ),
    ),
  );
}
