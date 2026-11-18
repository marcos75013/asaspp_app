class GalleryModel {
  final String id;
  final String title;
  final DateTime date;
  final String coverImage;
  final List<String> photos;
  final List<int> photoIds;
  final String type;

  GalleryModel({
    required this.id,
    required this.title,
    required this.date,
    required this.coverImage,
    required this.photos,
    this.photoIds = const [],
    required this.type,
  });

  factory GalleryModel.fromJson(
    Map<String, dynamic> json, {
    required String Function(String) resolveUrl,
  }) {
    final rawPhotos = json['photos'] as List<dynamic>? ?? const [];
    final photos =
        rawPhotos
            .whereType<Map>()
            .map((photo) => Map<String, dynamic>.from(photo))
            .toList()
          ..sort(
            (left, right) => ((left['position'] as num?)?.toInt() ?? 0)
                .compareTo((right['position'] as num?)?.toInt() ?? 0),
          );
    final coverPhotoId = (json['coverPhotoId'] as num?)?.toInt();
    final cover = photos.cast<Map<String, dynamic>?>().firstWhere(
      (photo) => (photo?['id'] as num?)?.toInt() == coverPhotoId,
      orElse: () => photos.isEmpty ? null : photos.first,
    );

    return GalleryModel(
      id: '${json['id'] ?? ''}',
      title: json['title'] as String? ?? '',
      date:
          DateTime.tryParse(json['outingDate'] as String? ?? '') ??
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      coverImage: cover == null
          ? ''
          : resolveUrl(cover['url'] as String? ?? ''),
      photos: photos
          .map((photo) => resolveUrl(photo['url'] as String? ?? ''))
          .where((url) => url.isNotEmpty)
          .toList(),
      photoIds: photos
          .where((photo) => (photo['url'] as String? ?? '').isNotEmpty)
          .map((photo) => (photo['id'] as num?)?.toInt() ?? 0)
          .toList(),
      type: (json['category'] as String?)?.trim().isNotEmpty == true
          ? (json['category'] as String).trim()
          : 'Sans catégorie',
    );
  }
}
