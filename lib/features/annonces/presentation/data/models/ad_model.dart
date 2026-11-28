enum AdType { vente, recherche, don }

class AdModel {
  final String id;
  final String title;
  final String description;
  final String _coverImage;
  final List<String> _images;
  final double price;
  final String sellerName;
  final String sellerAvatar;
  final int? authorId;
  final String? contactPhone;
  final String? sellerEmail;
  final DateTime createdAt;
  final AdType type;
  final bool isFavorite;

  const AdModel({
    required this.id,
    required this.title,
    required this.description,
    String image = '',
    List<String> images = const [],
    required this.price,
    required this.sellerName,
    required this.sellerAvatar,
    this.authorId,
    this.contactPhone,
    this.sellerEmail,
    required this.createdAt,
    required this.type,
    this.isFavorite = false,
  }) : _coverImage = image,
       _images = images;

  String get image => _images.firstOrNull ?? _coverImage;

  List<String> get images => _images.isNotEmpty
      ? _images
      : _coverImage.isNotEmpty
      ? [_coverImage]
      : const [];

  String get priceLabel => switch (type) {
    AdType.don => 'Gratuit',
    AdType.recherche => 'Recherche',
    AdType.vente =>
      '${price.toStringAsFixed(price % 1 == 0 ? 0 : 2).replaceAll('.', ',')} €',
  };

  String get typeLabel => switch (type) {
    AdType.vente => 'Vente',
    AdType.don => 'Don',
    AdType.recherche => 'Recherche',
  };

  AdModel copyWith({bool? isFavorite}) {
    return AdModel(
      id: id,
      title: title,
      description: description,
      image: _coverImage,
      images: _images,
      price: price,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      authorId: authorId,
      contactPhone: contactPhone,
      sellerEmail: sellerEmail,
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
      images: List.unmodifiable(
        images
            .map((image) => image['url'])
            .whereType<String>()
            .map((url) => url.trim())
            .where((url) => url.isNotEmpty)
            .map(resolveUrl)
            .where((url) => url.isNotEmpty),
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      sellerName: sellerName.isEmpty
          ? (json['authorEmail'] as String? ?? '')
          : sellerName,
      sellerAvatar: resolveUrl(json['authorAvatarUrl'] as String? ?? ''),
      authorId: (json['authorId'] as num?)?.toInt(),
      contactPhone: json['contactPhone'] as String?,
      sellerEmail: json['authorEmail'] as String?,
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
