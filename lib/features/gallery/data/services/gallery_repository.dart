import '../models/gallery_model.dart';

abstract interface class GalleryRepository {
  Future<List<GalleryModel>> getPublishedAlbums();
}
