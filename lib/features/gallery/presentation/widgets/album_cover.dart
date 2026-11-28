import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/pulse_theme.dart';
import '../../data/models/gallery_model.dart';

class AlbumCover extends StatelessWidget {
  const AlbumCover({
    super.key,
    required this.album,
    required this.aspectRatio,
    this.onTap,
    this.showPhotoCount = false,
  });

  final GalleryModel album;
  final double aspectRatio;
  final VoidCallback? onTap;
  final bool showPhotoCount;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(album.date);
    final photoCount = album.photos.length;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        borderRadius: PulseTheme.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GalleryImage(url: album.coverImage),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xED0B1020)],
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          showPhotoCount
                              ? '$date · $photoCount photo${photoCount == 1 ? '' : 's'}'
                              : date,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryImage extends StatelessWidget {
  const GalleryImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const fallback = DecoratedBox(
      decoration: BoxDecoration(gradient: PulseTheme.gradient),
      child: Center(
        child: Icon(Icons.photo_outlined, color: Colors.white, size: 30),
      ),
    );
    if (url.trim().isEmpty) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
