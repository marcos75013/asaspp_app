enum AdType { vente, recherche, don }

enum AdStatus {
  active('ACTIVE', 'En ligne'),
  closed('CLOSED', 'En pause'),
  sold('SOLD', 'Vendue');

  const AdStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class AdPhoto {
  const AdPhoto({required this.url, this.id});

  final String url;
  final int? id;
}

class AdModel {
  final String id;
  final String title;
  final String description;
  final String _coverImage;
  final List<String> _images;
  final List<AdPhoto> photos;
  final double price;
  final String sellerName;
  final String sellerAvatar;
  final int? authorId;
  final String? contactPhone;
  final String? sellerEmail;
  final DateTime createdAt;
  final AdType type;
  final bool isFavorite;
  final bool isOwner;
  final bool isActive;
  final AdStatus status;

  const AdModel({
    required this.id,
    required this.title,
    required this.description,
    String image = '',
    List<String> images = const [],
    this.photos = const [],
    required this.price,
    required this.sellerName,
    required this.sellerAvatar,
    this.authorId,
    this.contactPhone,
    this.sellerEmail,
    required this.createdAt,
    required this.type,
    this.isFavorite = false,
    this.isOwner = false,
    this.isActive = true,
    this.status = AdStatus.active,
  }) : _coverImage = image,
       _images = images;

  String get image =>
      photos.firstOrNull?.url ?? _images.firstOrNull ?? _coverImage;

  List<String> get images => photos.isNotEmpty
      ? photos.map((photo) => photo.url).toList(growable: false)
      : _images.isNotEmpty
      ? _images
      : _coverImage.isNotEmpty
      ? [_coverImage]
      : const [];

  String get visibilityLabel => isActive ? status.label : 'Masquée par le club';

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
      photos: photos,
      price: price,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      authorId: authorId,
      contactPhone: contactPhone,
      sellerEmail: sellerEmail,
      createdAt: createdAt,
      type: type,
      isFavorite: isFavorite ?? this.isFavorite,
      isOwner: isOwner,
      isActive: isActive,
      status: status,
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
      photos: List.unmodifiable(
        images
            .map((image) {
              final rawUrl = image['url'];
              final url = rawUrl is String && rawUrl.trim().isNotEmpty
                  ? resolveUrl(rawUrl.trim())
                  : '';
              return AdPhoto(url: url, id: (image['id'] as num?)?.toInt());
            })
            .where((photo) => photo.url.isNotEmpty),
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
      isOwner: json['owner'] == true,
      isActive: json['active'] != false,
      status: switch (json['status']) {
        'CLOSED' => AdStatus.closed,
        'SOLD' => AdStatus.sold,
        _ => AdStatus.active,
      },
    );
  }
}
