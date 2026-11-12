import 'package:asaspp_app/features/ducumentslib/data/models/association_document_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a published backend document', () {
    final document = AssociationDocumentModel.fromJson({
      'id': 7,
      'categoryId': 2,
      'categoryName': 'Règlement',
      'title': 'Règlement intérieur',
      'description': 'Version 2026',
      'originalFilename': 'reglement.pdf',
      'contentType': 'application/pdf',
      'fileSize': 1024,
      'createdAt': '2026-11-12T12:00:00',
    });

    expect(document.id, 7);
    expect(document.categoryName, 'Règlement');
    expect(document.originalFilename, 'reglement.pdf');
    expect(document.isPdf, isTrue);
  });

  test('parses a document without category', () {
    final document = AssociationDocumentModel.fromJson({
      'id': 8,
      'title': 'Informations',
    });

    expect(document.categoryId, isNull);
    expect(document.categoryName, 'Sans catégorie');
    expect(document.isPdf, isFalse);
  });
}
