class PhotoDiscussion {
  final int likes;
  final bool liked;
  final List<PhotoComment> comments;

  const PhotoDiscussion({
    required this.likes,
    required this.liked,
    required this.comments,
  });

  factory PhotoDiscussion.fromJson(Map<String, dynamic> json) {
    return PhotoDiscussion(
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      liked: json['liked'] == true,
      comments: (json['comments'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => PhotoComment.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class PhotoComment {
  final int id;
  final String author;
  final String body;
  final String? authorAvatarUrl;
  final DateTime? createdAt;

  const PhotoComment({
    required this.id,
    required this.author,
    required this.body,
    this.authorAvatarUrl,
    this.createdAt,
  });

  factory PhotoComment.fromJson(Map<String, dynamic> json) {
    return PhotoComment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      author: json['author'] as String? ?? 'Membre',
      body: json['body'] as String? ?? '',
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
