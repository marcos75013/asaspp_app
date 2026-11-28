import 'package:asaspp_app/features/annonces/presentation/data/models/ad_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a marketplace listing returned by the backend', () {
    final ad = AdModel.fromJson({
      'id': 42,
      'authorFirstName': 'Jean',
      'authorLastName': 'Martin',
      'authorEmail': 'jean@example.test',
      'contactPhone': '+33123456789',
      'type': 'SALE',
      'title': 'Détendeur',
      'description': 'Révisé cette année',
      'price': 120.50,
      'favorite': true,
      'createdAt': '2026-11-12T09:00:00',
      'images': [
        {'id': 2, 'url': '/uploads/marketplace/1/second.jpg', 'position': 1},
        {'id': 1, 'url': '/uploads/marketplace/1/first.jpg', 'position': 0},
        {'id': 3, 'url': '', 'position': -1},
      ],
    }, resolveUrl: (url) => 'http://localhost:8080$url');

    expect(ad.id, '42');
    expect(ad.sellerName, 'Jean Martin');
    expect(ad.sellerEmail, 'jean@example.test');
    expect(ad.contactPhone, '+33123456789');
    expect(ad.type, AdType.vente);
    expect(ad.price, 120.50);
    expect(ad.isFavorite, isTrue);
    expect(ad.image, 'http://localhost:8080/uploads/marketplace/1/first.jpg');
    expect(ad.images, [
      'http://localhost:8080/uploads/marketplace/1/first.jpg',
      'http://localhost:8080/uploads/marketplace/1/second.jpg',
    ]);
    expect(ad.copyWith(isFavorite: false).images, ad.images);
  });

  test('maps wanted and gift listing types', () {
    AdModel parse(String type) =>
        AdModel.fromJson({'type': type}, resolveUrl: (url) => url);

    expect(parse('WANTED').type, AdType.recherche);
    expect(parse('GIFT').type, AdType.don);
  });
}
