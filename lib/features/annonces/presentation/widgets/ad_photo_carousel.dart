import 'package:flutter/gestures.dart' show PointerDeviceKind;
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

  Widget _photo(int index, {String? heroTag}) {
    final url = widget.images.elementAtOrNull(index) ?? '';
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
            builder: (_) =>
                _FullScreenPhoto(images: widget.images, initialIndex: index),
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
                ? _photo(0, heroTag: widget.adId)
                : PageView.builder(
                    controller: _controller,
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) => Semantics(
                      image: true,
                      label: 'Photo ${index + 1} sur ${images.length}',
                      child: _photo(index),
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
  const _FullScreenPhoto({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_FullScreenPhoto> createState() => _FullScreenPhotoState();
}

class _FullScreenPhotoState extends State<_FullScreenPhoto> {
  final _zoom = TransformationController();
  final _touchPointers = <int>{};
  late int _index = widget.initialIndex;
  Offset? _swipeStart;

  void _move(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.images.length) return;
    _swipeStart = null;
    _zoom.value = Matrix4.identity();
    setState(() => _index = next);
  }

  // Observe touches without taking pinch or pan gestures from InteractiveViewer.
  void _onPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.touch || widget.images.length < 2) {
      return;
    }
    _touchPointers.add(event.pointer);
    _swipeStart =
        _touchPointers.length == 1 && _zoom.value.getMaxScaleOnAxis() <= 1.01
        ? event.position
        : null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_touchPointers.remove(event.pointer)) _swipeStart = null;
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_touchPointers.remove(event.pointer)) return;
    final start = _swipeStart;
    _swipeStart = null;
    if (start == null) return;

    final distance = event.position - start;
    if (distance.dx.abs() >= 64 &&
        distance.dx.abs() > distance.dy.abs() * 1.25) {
      _move(distance.dx < 0 ? 1 : -1);
    }
  }

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
      bottomNavigationBar: widget.images.length > 1
          ? SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Photo précédente en plein écran',
                    color: Colors.white,
                    disabledColor: Colors.white38,
                    onPressed: _index == 0 ? null : () => _move(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      '${_index + 1} / ${widget.images.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Photo suivante en plein écran',
                    color: Colors.white,
                    disabledColor: Colors.white38,
                    onPressed: _index == widget.images.length - 1
                        ? null
                        : () => _move(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            )
          : null,
      body: SafeArea(
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerCancel: _onPointerCancel,
          onPointerUp: _onPointerUp,
          child: SizedBox.expand(
            child: InteractiveViewer(
              key: ValueKey(_index),
              transformationController: _zoom,
              minScale: 1,
              maxScale: 5,
              child: Image.network(
                widget.images[_index],
                fit: BoxFit.contain,
                semanticLabel:
                    'Photo ${_index + 1} sur ${widget.images.length}',
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
      ),
    );
  }
}
