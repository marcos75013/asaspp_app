import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/club_api.dart';
import 'club_widgets.dart';
import 'collection_page.dart';

class ConnectedGallery extends StatelessWidget {
  final ClubApi api;
  final bool embedded;
  const ConnectedGallery({super.key, required this.api, this.embedded = false});
  @override
  Widget build(BuildContext context) => CollectionPage(
    api: api,
    path: '/api/gallery',
    embedded: embedded,
    title: 'Galerie photo',
    subtitle: 'Retrouvez les photos et les albums du club.',
    itemBuilder: (context, album, refresh) {
      final photos = records(album['photos'] ?? []);
      final cover =
          photos.where((p) => p['id'] == album['coverPhotoId']).firstOrNull ??
          photos.firstOrNull;
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openPage(context, AlbumPage(api: api, album: album)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClubImage(
                  cover == null ? null : api.imageUrl(label(cover, 'url')),
                  height: 220,
                ),
                const SizedBox(height: 16),
                Text(
                  label(album, 'title'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${photos.length} photo(s)',
                  style: const TextStyle(color: teal),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class AlbumPage extends StatelessWidget {
  final ClubApi api;
  final Json album;
  const AlbumPage({super.key, required this.api, required this.album});
  @override
  Widget build(BuildContext context) {
    final photos = records(album['photos'] ?? []);
    return Scaffold(
      appBar: AppBar(title: Text(label(album, 'title'))),
      body: PageBody(
        children: [
          Heading(
            label(album, 'title'),
            label(
              album,
              'description',
              '${photos.length} souvenirs à partager.',
            ),
          ),
          if (photos.isEmpty)
            const StatusPanel(
              title: 'Un album à remplir',
              message: 'Les photos arrivent bientôt.',
            ),
          LayoutBuilder(
            builder: (context, constraints) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 650 ? 3 : 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) => Semantics(
                label: 'Afficher la photo ${index + 1}',
                button: true,
                child: InkWell(
                  onTap: () => openPage(
                    context,
                    PhotoPage(api: api, photos: photos, initial: index),
                  ),
                  child: ClubImage(api.imageUrl(label(photos[index], 'url'))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoPage extends StatelessWidget {
  final ClubApi api;
  final List<Json> photos;
  final int initial;
  const PhotoPage({
    super.key,
    required this.api,
    required this.photos,
    required this.initial,
  });
  @override
  Widget build(BuildContext context) =>
      _PhotoViewer(api: api, photos: photos, initial: initial);
}

class _PhotoViewer extends StatefulWidget {
  final ClubApi api;
  final List<Json> photos;
  final int initial;
  const _PhotoViewer({
    required this.api,
    required this.photos,
    required this.initial,
  });
  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final _controller = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(
      backgroundColor: ink,
      foregroundColor: Colors.white,
      title: Text('${_index + 1} / ${widget.photos.length}'),
    ),
    body: PageView.builder(
      controller: _controller,
      itemCount: widget.photos.length,
      onPageChanged: (index) => setState(() => _index = index),
      itemBuilder: (context, index) => InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Image.network(
            widget.api.imageUrl(label(widget.photos[index], 'url')),
            errorBuilder: (_, error, stack) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    ),
  );
}

class ConnectedDocuments extends StatelessWidget {
  final ClubApi api;
  const ConnectedDocuments({super.key, required this.api});
  @override
  Widget build(BuildContext context) => CollectionPage(
    api: api,
    path: '/api/documents',
    title: 'Bibliothèque',
    subtitle: 'Les ressources de votre association, à portée de main.',
    itemBuilder: (context, document, refresh) =>
        DocumentCard(api: api, document: document),
  );
}

class DocumentCard extends StatefulWidget {
  final ClubApi api;
  final Json document;
  const DocumentCard({super.key, required this.api, required this.document});
  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool _busy = false;
  Future<void> _download() async {
    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    await runAction(context, () async {
      final bytes =
          await widget.api.request(
                '/api/documents/${widget.document['id']}/download',
                responseType: ResponseType.bytes,
              )
              as List<int>;
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(bytes),
              mimeType: label(
                widget.document,
                'contentType',
                'application/octet-stream',
              ),
            ),
          ],
          fileNameOverrides: [
            label(widget.document, 'originalFilename', 'document'),
          ],
          sharePositionOrigin: origin,
        ),
      );
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: mint,
                child: Icon(Icons.description_outlined, color: teal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label(widget.document, 'title'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(label(widget.document, 'description')),
          const SizedBox(height: 10),
          Text(
            '${label(widget.document, 'categoryName', 'Document')} · '
            '${((widget.document['fileSize'] as num? ?? 0) / 1024).ceil()} Ko',
            style: const TextStyle(color: teal),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _busy ? null : _download,
            icon: const Icon(Icons.ios_share),
            label: Text(_busy ? 'Préparation…' : 'Enregistrer ou partager'),
          ),
        ],
      ),
    ),
  );
}
