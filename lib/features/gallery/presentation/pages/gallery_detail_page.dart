import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../data/models/gallery_model.dart';

class GalleryDetailPage extends StatefulWidget {
  final GalleryModel gallery;

  const GalleryDetailPage({super.key, required this.gallery});

  @override
  State<GalleryDetailPage> createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.gallery.title),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.gallery.photos.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider:
                AssetImage(widget.gallery.photos[index]),
                heroAttributes: PhotoViewHeroAttributes(
                    tag: widget.gallery.id),
              );
            },
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${currentIndex + 1} / ${widget.gallery.photos.length}',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
