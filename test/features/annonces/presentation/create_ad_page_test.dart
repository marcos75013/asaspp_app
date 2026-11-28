import 'dart:convert';

import 'package:asaspp_app/core/theme/pulse_theme.dart';
import 'package:asaspp_app/features/annonces/data/services/ads_repository.dart';
import 'package:asaspp_app/features/annonces/presentation/data/models/ad_model.dart';
import 'package:asaspp_app/features/annonces/presentation/pages/create_ad_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class _PhotoPicker extends ImagePicker {
  int picks = 0;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    expect(source, ImageSource.gallery);
    final name = 'photo-${++picks}.png';
    return XFile.fromData(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jCqsAAAAASUVORK5CYII=',
      ),
      path: name,
      name: name,
      mimeType: 'image/png',
    );
  }
}

class _AdsRepository implements AdsRepository {
  CreateAdInput? input;
  List<AdImageUpload> uploaded = const [];

  @override
  Future<AdModel> createAd(
    CreateAdInput input,
    List<AdImageUpload> images,
  ) async {
    this.input = input;
    uploaded = images;
    return AdModel(
      id: '1',
      title: input.title,
      description: input.description,
      price: input.price ?? 0,
      image: '',
      sellerName: 'Camille',
      sellerAvatar: '',
      createdAt: DateTime(2026),
      type: input.type,
    );
  }

  @override
  Future<AdModel> getAd(String id) => throw UnimplementedError();

  @override
  Future<AdModel> setStatus(String id, AdStatus status) =>
      throw UnimplementedError();

  @override
  Future<List<AdModel>> getAds() async => [];

  @override
  Future<AdModel> toggleFavorite(String id) => throw UnimplementedError();
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'validates, reorders photos and returns in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repository = _AdsRepository();
        bool? published;

        await tester.pumpWidget(
          MaterialApp(
            theme: PulseTheme.build(brightness),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    published = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => CreateAdPage(
                          repository: repository,
                          imagePicker: _PhotoPicker(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Liste des annonces'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Liste des annonces'));
        await tester.pumpAndSettle();

        Future<void> tapVisible(Finder finder) async {
          await tester.ensureVisible(finder);
          await tester.tap(finder);
          await tester.pumpAndSettle();
        }

        final submit = find.text('Publier mon annonce');
        await tapVisible(submit);
        expect(find.text('Ce champ est obligatoire.'), findsNWidgets(2));
        expect(repository.input, isNull);

        final addPhoto = find.text('Ajouter des photos');
        await tapVisible(addPhoto);
        await tapVisible(addPhoto);
        await tapVisible(addPhoto);
        expect(find.text('3/5 photos'), findsOneWidget);
        await tapVisible(find.byTooltip('Déplacer la photo 2 vers la gauche'));
        await tapVisible(find.byTooltip('Déplacer la photo 2 vers la droite'));
        await tapVisible(find.byTooltip('Retirer la photo 2'));
        expect(find.text('2/5 photos'), findsOneWidget);
        expect(find.bySemanticsLabel('Photo 1'), findsOneWidget);

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'Masque de plongée');
        await tester.enterText(fields.at(1), 'NaN');
        await tester.enterText(fields.at(2), 'En bon état');
        await tapVisible(submit);
        expect(find.text('Indiquez un prix supérieur à zéro.'), findsOneWidget);
        expect(repository.input, isNull);

        await tester.enterText(fields.at(1), '25,50');
        await tapVisible(submit);
        expect(repository.input?.title, 'Masque de plongée');
        expect(repository.input?.price, 25.50);
        expect(repository.uploaded.map((photo) => photo.filename), [
          'photo-2.png',
          'photo-1.png',
        ]);
        expect(
          repository.uploaded.every((photo) => photo.bytes.isNotEmpty),
          isTrue,
        );
        expect(published, isTrue);
        expect(find.text('Liste des annonces'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
