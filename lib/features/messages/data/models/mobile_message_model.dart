class MobileMessageModel {
  final int id;
  final String title;
  final String content;
  final String? authorFirstName;
  final String? authorLastName;
  final String? authorAvatarUrl;
  final DateTime createdAt;

  const MobileMessageModel({
    required this.id,
    required this.title,
    required this.content,
    this.authorFirstName,
    this.authorLastName,
    this.authorAvatarUrl,
    required this.createdAt,
  });

  String get authorName {
    return [
      authorFirstName,
      authorLastName,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
  }

  factory MobileMessageModel.fromJson(Map<String, dynamic> json) {
    return MobileMessageModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorFirstName: json['authorFirstName'],
      authorLastName: json['authorLastName'],
      authorAvatarUrl: json['createdByAvatarUrl'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
