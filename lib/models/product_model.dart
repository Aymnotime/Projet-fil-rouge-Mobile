class ProductModel {
  final String id; // Ajout de l'id
  final String image;
  final String title;
  final String brandName;
  final String description; // Ajout du champ description
  final double price;
  final double? priceAfterDiscount;  // Peut être null si pas de promo
  final int? discountPercent;        // Peut être null si pas de promo

  ProductModel({
    required this.id, // Ajouté
    required this.image,
    required this.title,
    required this.brandName,
    required this.description, // Ajouté
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
  });

  // Constructeur depuis JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '', // Mapping id
      image: json['image'] ?? '',
      title: json['nom'] ?? '',
      brandName: json['brandName'] ?? '',
      description: json['description'] ?? '', // Mapping description
      price: (json['prix'] as num?)?.toDouble() ?? 0.0,
      priceAfterDiscount: json['priceAfterDiscount'] != null
          ? (json['priceAfterDiscount'] as num).toDouble()
          : null,
      discountPercent: json['discountPercent'] != null
          ? json['discountPercent'] as int
          : null,
    );
  }

  // Méthode pour calculer le prix après remise, si pas fourni
  double get computedPriceAfterDiscount {
    if (priceAfterDiscount != null) {
      return priceAfterDiscount!;
    }
    if (discountPercent != null) {
      return price * (1 - discountPercent! / 100);
    }
    return price;
  }
}
