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
                ? Hero(
                    tag: widget.adId,
                    child: AdImage(
                      url: images.firstOrNull ?? '',
                      fit: BoxFit.contain,
                    ),
                  )
                : PageView.builder(
                    controller: _controller,
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) => Semantics(
                      image: true,
                      label: 'Photo ${index + 1} sur ${images.length}',
                      child: AdImage(url: images[index], fit: BoxFit.contain),
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
