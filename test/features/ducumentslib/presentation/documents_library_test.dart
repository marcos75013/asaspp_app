import 'package:asaspp_app/features/ducumentslib/data/models/association_document_model.dart';
import 'package:asaspp_app/features/ducumentslib/data/services/documents_repository.dart';
import 'package:asaspp_app/features/ducumentslib/presentation/documents_library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDocuments implements DocumentsRepository {
  int opened = 0;
  @override
  Future<List<DocumentCategoryModel>> getCategories() async => [];
  @override
  Future<List<AssociationDocumentModel>> getPublishedDocuments() async => [
    AssociationDocumentModel(
      id: 1,
      categoryId: null,
      categoryName: 'Sans catégorie',
      title: 'Règlement',
      description: '',
      originalFilename: 'reglement.pdf',
      contentType: 'application/pdf',
      fileSize: 10,
      createdAt: DateTime(2026),
    ),
    AssociationDocumentModel(
      id: 2,
      categoryId: null,
      categoryName: 'Sans catégorie',
      title: 'Fédération',
      description: '',
      originalFilename: '',
      contentType: 'text/uri-list',
      fileSize: 0,
      createdAt: DateTime(2026),
      externalUrl: 'https://example.org',
    ),
  ];
  @override
  Future<void> openFile(AssociationDocumentModel document) async {
    opened = document.id;
  }
}

void main() {
  testWidgets('shows links and documents and opens a document', (tester) async {
    final repo = FakeDocuments();
    await tester.pumpWidget(
      MaterialApp(home: DocumentsLibraryPage(repository: repo)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Règlement'), findsOneWidget);
    expect(find.text('Fédération'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    expect(find.byIcon(Icons.link), findsOneWidget);
    await tester.tap(find.byIcon(Icons.open_in_new).first);
    await tester.pump();
    expect(repo.opened, 1);
  });
}
