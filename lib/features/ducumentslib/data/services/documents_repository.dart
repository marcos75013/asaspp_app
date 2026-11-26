import '../models/association_document_model.dart';

abstract interface class DocumentsRepository {
  Future<List<AssociationDocumentModel>> getPublishedDocuments();
  Future<List<DocumentCategoryModel>> getCategories();
  Future<void> openFile(AssociationDocumentModel document);
}
