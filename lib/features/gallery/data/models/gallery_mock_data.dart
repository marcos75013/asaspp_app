import 'gallery_model.dart';

final List<GalleryModel> mockGalleries = [
  GalleryModel(
    id: '1',
    title: 'Carrière de Beaumont',
    date: DateTime(2026, 2, 15),
    type: 'Carrière',
    coverImage: 'assets/gallery/gallery1.jpg',
    photos: [
      'assets/gallery/gallery2.jpg',
      'assets/gallery/gallery3.jpeg',
    ],
  ),
  GalleryModel(
    id: '2',
    title: 'Sortie Mer - Marseille',
    date: DateTime(2025, 7, 20),
    type: 'Mer',
    coverImage: 'assets/gallery/gallery5.jpg',
    photos: [
      'assets/gallery/gallery6.jpg',
      'assets/gallery/gallery7.jpg',
    ],
  ),
  GalleryModel(
    id: '3',
    title: 'Fosse de Villeneuve',
    date: DateTime(2025, 11, 10),
    type: 'Fosse',
    coverImage: 'assets/gallery/gallery8.jpg',
    photos: [
      'assets/gallery/gallery91.jpg',
    ],
  ),
  GalleryModel(
    id: '4',
    title: 'Plongée Nuit - Étretat',
    date: DateTime(2024, 9, 18),
    type: 'Nuit',
    coverImage: 'assets/gallery/gallery2.jpg',
    photos: [
      'assets/gallery/gallery3.jpeg',
    ],
  ),
  GalleryModel(
    id: '5',
    title: 'Apéro Club ASASPP',
    date: DateTime(2024, 6, 5),
    type: 'Apéro',
    coverImage: 'assets/gallery/gallery4.jpg',
    photos: [
      'assets/gallery/gallery5.jpg',
    ],
  ),
];
