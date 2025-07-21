class ProductModel {
  final String id;
  final String image;
  final String title;
  final String brandName;
  final String description;
  final double price;
  final double? prix_promo; // Le prix promo de la BDD est mappé ici
  final String? categorie;
  final bool isNew;
  final bool isBestSeller;
  final bool isFlashSale;
  final bool isPopular;

  ProductModel({
    required this.id,
    required this.image,
    required this.title,
    required this.brandName,
    required this.description,
    required this.price,
    this.prix_promo,
    this.categorie,
    this.isNew = false,
    this.isBestSeller = false,
    this.isFlashSale = false,
    this.isPopular = false,
  });

  // Constructeur depuis JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic v) => v == true || v == 1 || v == '1';
    return ProductModel(
      id: json['id']?.toString() ?? '',
      image: json['image'] ?? '',
      title: json['nom'] ?? '',
      brandName: json['brand_name'] ?? '',
      description: json['description'] ?? '',
      price: (json['prix'] as num?)?.toDouble() ?? 0.0,
      prix_promo: json['prix_promo'] != null
          ? (json['prix_promo'] is num
          ? (json['prix_promo'] as num).toDouble()
          : double.tryParse(json['prix_promo'].toString()))
          : null,
      categorie: json['categorie'] ?? '',
      isNew: parseBool(json['isNew']),
      isBestSeller: parseBool(json['isBestSeller']),
      isFlashSale: parseBool(json['isFlashSale']),
      isPopular: parseBool(json['isPopular']),
    );
  }

  // Retourne le prix à afficher (promo si présent, sinon calcul, sinon prix normal)
  double get displayPrice {
    if (prix_promo != null && prix_promo! > 0 && prix_promo! < price) {
      return prix_promo!;
    }
    return price;
  }

  // Indique si le produit est en promo
// ...
  bool get isPromo => prix_promo != null && prix_promo! > 0 && prix_promo! < price;
}
