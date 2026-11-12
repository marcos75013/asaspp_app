class AssociationDocumentModel {
  final int id;
  final int? categoryId;
  final String categoryName;
  final String title;
  final String description;
  final String originalFilename;
  final String contentType;
  final int fileSize;
  final DateTime createdAt;

  const AssociationDocumentModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.originalFilename,
    required this.contentType,
    required this.fileSize,
    required this.createdAt,
  });

  factory AssociationDocumentModel.fromJson(Map<String, dynamic> json) {
    return AssociationDocumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      categoryName: json['categoryName'] as String? ?? 'Sans catégorie',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      originalFilename: json['originalFilename'] as String? ?? 'document',
      contentType: json['contentType'] as String? ?? 'application/octet-stream',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool get isPdf => contentType == 'application/pdf';
}

class DocumentCategoryModel {
  final int id;
  final String name;

  const DocumentCategoryModel({required this.id, required this.name});

  factory DocumentCategoryModel.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}
