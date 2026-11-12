import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/association_document_model.dart';
import 'documents_repository.dart';

class MobileDocumentsApiService implements DocumentsRepository {
  final ApiClient _apiClient;

  MobileDocumentsApiService(this._apiClient);

  @override
  Future<List<AssociationDocumentModel>> getPublishedDocuments() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/api/documents');
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
  Future<Uri> download(AssociationDocumentModel document) async {
    final response = await _apiClient.dio.get<Uint8List>(
      '/api/documents/${document.id}/download',
      options: Options(responseType: ResponseType.bytes),
    );
    final safeFilename = document.originalFilename.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final file = File(
      '${Directory.systemTemp.path}/multiasso_${document.id}_$safeFilename',
    );
    await file.writeAsBytes(response.data ?? Uint8List(0), flush: true);
    return file.uri;
  }
}
