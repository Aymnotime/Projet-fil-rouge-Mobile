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
}

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "Woman’s", image: "https://i.imgur.com/5M89G2P.png"),
  CategoryModel(title: "Man’s", image: "https://i.imgur.com/UM3GdWg.png"),
  CategoryModel(title: "Accessories", image: "https://i.imgur.com/3mSE5sN.png"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    title: "En vente",
    svgSrc: "assets/icons/Sale.svg",
    subCategories: [
      CategoryModel(title: "Nos Produits"),
      CategoryModel(title: "Nouveau"),
      CategoryModel(title: "PC Gamer"),
      CategoryModel(title: "Ecran"),
      CategoryModel(title: "Casque"),
    ],
  ),
  CategoryModel(
    title: "Tendances",
    svgSrc: "assets/icons/fire.svg",
    subCategories: [
      CategoryModel(title: "Ecran"),
      CategoryModel(title: "Pc Gamer"),
      CategoryModel(title: "Carte Graphique"),
    ],
  ),


  CategoryModel(
    title: "Accessoires",
    svgSrc: "assets/icons/Accessories.svg",
    subCategories: [
      CategoryModel(title: "Casque VR"),
      CategoryModel(title: "Clavier"),
    ],
  ),
];
