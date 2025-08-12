import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:shop/models/category_model.dart';
import 'package:shop/services/api/product_api.dart';
import '../../../../constants.dart';

class Categories extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const Categories({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  Future<List<CategoryModel>> fetchCategories() async {
    final items = await fetchCategoriesFromApi();
    return items.map<CategoryModel>((item) => CategoryModel(
      title: item['nom'] ?? '',
      svgSrc: null, // À adapter si tu ajoutes une icône en BDD
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryModel>>(
      future: fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Aucune catégorie trouvée'));
        }
        final categories = snapshot.data!;
        final allCategories = [CategoryModel(title: 'Tous les produits', svgSrc: null), ...categories];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(
                allCategories.length,
                    (index) => Padding(
                  padding: EdgeInsets.only(
                      left: index == 0 ? defaultPadding : defaultPadding / 2,
                      right: index == allCategories.length - 1 ? defaultPadding : 0),
                  child: CategoryBtn(
                    category: allCategories[index].title,
                    svgSrc: allCategories[index].svgSrc,
                    isActive: selectedCategory == allCategories[index].title,
                    press: () {
                      onCategorySelected(allCategories[index].title);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    required this.isActive,
    required this.press,
  });

  final String category;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : Theme.of(context).dividerColor),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.asset(
                svgSrc!,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            if (svgSrc != null) const SizedBox(width: defaultPadding / 2),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// For preview
// class CategoryModel {
//   final String title;
//   final String? svgSrc;
//   // final String? route; // supprimé car non utilisé dans le modèle dynamique
//
//   CategoryModel({
//     required this.title,
//     this.svgSrc,
//   });
// }

// List<CategoryModel> demoCategories = [
//   CategoryModel(title: "All Categories"),
//   CategoryModel(
//       title: "Meilleures ventes",
//       svgSrc: "assets/icons/Sale.svg"),
//   CategoryModel(title: "PC", svgSrc: "assets/icons/video-games.png"),
//   CategoryModel(title: "Ecran", svgSrc: "assets/icons/screen.svg"),
// ];
/// End For Preview
