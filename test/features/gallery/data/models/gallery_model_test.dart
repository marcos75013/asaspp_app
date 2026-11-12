import 'package:asaspp_app/features/gallery/data/models/gallery_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses and orders a published backend album', () {
    final album = GalleryModel.fromJson({
      'id': 12,
      'title': 'Sortie en mer',
      'createdAt': '2026-11-12T10:30:00',
      'coverPhotoId': 2,
      'photos': [
        {'id': 2, 'url': '/uploads/gallery/1/12/cover.jpg', 'position': 1},
        {'id': 1, 'url': '/uploads/gallery/1/12/first.jpg', 'position': 0},
      ],
    }, resolveUrl: (url) => 'http://localhost:8080$url');

    expect(album.id, '12');
    expect(album.title, 'Sortie en mer');
    expect(
      album.coverImage,
      'http://localhost:8080/uploads/gallery/1/12/cover.jpg',
    );
    expect(album.photos, [
      'http://localhost:8080/uploads/gallery/1/12/first.jpg',
      'http://localhost:8080/uploads/gallery/1/12/cover.jpg',
    ]);
  });

  test('supports an album without photos', () {
    final album = GalleryModel.fromJson({
      'id': 13,
      'title': 'Album vide',
      'photos': <dynamic>[],
    }, resolveUrl: (url) => url);

    expect(album.coverImage, isEmpty);
    expect(album.photos, isEmpty);
  });
}
