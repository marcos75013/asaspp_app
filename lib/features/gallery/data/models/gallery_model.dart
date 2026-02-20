class GalleryModel {
  final String id;
  final String title;
  final DateTime date;
  final String coverImage;
  final List<String> photos;
  final String type;

  GalleryModel({
    required this.id,
    required this.title,
    required this.date,
    required this.coverImage,
    required this.photos,
    required this.type,
  });
}
