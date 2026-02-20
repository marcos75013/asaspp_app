enum AdType { vente, recherche, don }

class AdModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final double price;
  final String sellerName;
  final String sellerAvatar;
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
    required this.createdAt,
    required this.type,
    this.isFavorite = false,
  });

  AdModel copyWith({
    bool? isFavorite,
  }) {
    return AdModel(
      id: id,
      title: title,
      description: description,
      image: image,
      price: price,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      createdAt: createdAt,
      type: type,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
