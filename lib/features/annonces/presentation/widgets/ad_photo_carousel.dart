import 'package:flutter/material.dart';

import '../../../../core/theme/pulse_theme.dart';
import 'ad_image.dart';

class AdPhotoCarousel extends StatefulWidget {
  const AdPhotoCarousel({super.key, required this.adId, required this.images});

  final String adId;
  final List<String> images;

  @override
  State<AdPhotoCarousel> createState() => _AdPhotoCarouselState();
}

class _AdPhotoCarouselState extends State<AdPhotoCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(int offset) {
    _controller.animateToPage(
      _index + offset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Widget _photo(String url, {String? heroTag}) {
    final preview = AdImage(url: url, fit: BoxFit.contain);
    final image = heroTag == null
        ? preview
        : Hero(tag: heroTag, child: preview);
    if (url.isEmpty) return image;
    return Tooltip(
      message: 'Agrandir la photo',
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => _FullScreenPhoto(url: url),
          ),
        ),
        child: image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        ClipRRect(
          borderRadius: PulseTheme.cardRadius,
          child: AspectRatio(
            aspectRatio: 1.65,
            child: images.length <= 1
                ? _photo(images.firstOrNull ?? '', heroTag: widget.adId)
                : PageView.builder(
                    controller: _controller,
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) => Semantics(
                      image: true,
                      label: 'Photo ${index + 1} sur ${images.length}',
                      child: _photo(images[index]),
                    ),
                  ),
          ),
        ),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Photo précédente',
                onPressed: _index > 0 ? () => _move(-1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Semantics(
                liveRegion: true,
                child: Text(
                  '${_index + 1} / ${images.length}',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
              IconButton(
                tooltip: 'Photo suivante',
                onPressed: _index < images.length - 1 ? () => _move(1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
      ],
    );
  }
}

class _FullScreenPhoto extends StatefulWidget {
  const _FullScreenPhoto({required this.url});

  final String url;

  @override
  State<_FullScreenPhoto> createState() => _FullScreenPhotoState();
}

class _FullScreenPhotoState extends State<_FullScreenPhoto> {
  final _zoom = TransformationController();

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Fermer le plein écran',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            tooltip: 'Réinitialiser le zoom',
            onPressed: () => _zoom.value = Matrix4.identity(),
            icon: const Icon(Icons.zoom_out_map),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: InteractiveViewer(
            transformationController: _zoom,
            maxScale: 5,
            child: Image.network(
              widget.url,
              fit: BoxFit.contain,
              semanticLabel: 'Photo de l’annonce en plein écran',
              errorBuilder: (_, _, _) => const Center(
                child: Text(
                  'Impossible d’afficher cette photo.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
