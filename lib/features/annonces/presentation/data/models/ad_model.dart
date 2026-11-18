enum AdType { vente, recherche, don }

class AdModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final double price;
  final String sellerName;
  final String sellerAvatar;
  final int? authorId;
  final DateTime createdAt;
  final AdType type;
  final bool isFavorite;

  const AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.sellerName,
    required this.sellerAvatar,
    this.authorId,
    required this.createdAt,
    required this.type,
    this.isFavorite = false,
  });

  AdModel copyWith({bool? isFavorite}) {
    return AdModel(
      id: id,
      title: title,
      description: description,
      image: image,
      price: price,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      authorId: authorId,
      createdAt: createdAt,
      type: type,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory AdModel.fromJson(
    Map<String, dynamic> json, {
    required String Function(String) resolveUrl,
  }) {
    final images =
        (json['images'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((image) => Map<String, dynamic>.from(image))
            .toList()
          ..sort(
            (left, right) => ((left['position'] as num?)?.toInt() ?? 0)
                .compareTo((right['position'] as num?)?.toInt() ?? 0),
          );
    final firstName = json['authorFirstName'] as String? ?? '';
    final lastName = json['authorLastName'] as String? ?? '';
    final sellerName = '$firstName $lastName'.trim();

    return AdModel(
      id: '${json['id'] ?? ''}',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: images.isEmpty
          ? ''
          : resolveUrl(images.first['url'] as String? ?? ''),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      sellerName: sellerName.isEmpty
          ? (json['authorEmail'] as String? ?? '')
          : sellerName,
      sellerAvatar: resolveUrl(json['authorAvatarUrl'] as String? ?? ''),
      authorId: (json['authorId'] as num?)?.toInt(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: switch (json['type']) {
        'WANTED' => AdType.recherche,
        'GIFT' => AdType.don,
        _ => AdType.vente,
      },
      isFavorite: json['favorite'] as bool? ?? false,
    );
  }
}
