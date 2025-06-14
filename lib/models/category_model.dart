class CategoryModel {
  final String title;
  final String? image, svgSrc;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });

  // Constructeur depuis JSON (pour API dynamique)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      title: json['nom'] ?? json['name'] ?? json['title'] ?? '',
      image: json['image'],
      svgSrc: json['svgSrc'],
      subCategories: null, // À adapter si tu veux gérer les sous-catégories dynamiquement
    );
  }
}
