import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/association_document_model.dart';
import 'documents_repository.dart';
import 'file_open/file_open.dart';

class MobileDocumentsApiService implements DocumentsRepository {
  final ApiClient _apiClient;

  MobileDocumentsApiService(this._apiClient);

  @override
  Future<List<AssociationDocumentModel>> getPublishedDocuments() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/documents',
      queryParameters: {'includeLinks': true},
    );
    return (response.data ?? const [])
        .map(
          (item) => AssociationDocumentModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<DocumentCategoryModel>> getCategories() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/documents/categories',
    );
    return (response.data ?? const [])
        .map(
          (item) => DocumentCategoryModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> openFile(AssociationDocumentModel document) async {
    final response = await _apiClient.dio.get<Uint8List>(
      '/api/documents/${document.id}/download',
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) throw StateError('Fichier vide');
    await openDownloadedDocument(
      bytes,
      document.originalFilename,
      document.contentType,
    );
  }
}
