import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'categories.dart';
import 'offers_carousel.dart';

class OffersCarouselAndCategories extends StatefulWidget {
  const OffersCarouselAndCategories({
    super.key,
  });

  @override
  State<OffersCarouselAndCategories> createState() => _OffersCarouselAndCategoriesState();
}

class _OffersCarouselAndCategoriesState extends State<OffersCarouselAndCategories> {
  String selectedCategory = 'Tous les produits';

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      // Ici, tu peux aussi notifier le parent ou filtrer les produits si besoin
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // While loading use 👇
        // const OffersSkelton(),
        const OffersCarousel(),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Categories",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading use 👇
        // const CategoriesSkelton(),
        Categories(
          selectedCategory: selectedCategory,
          onCategorySelected: _onCategorySelected,
        ),
      ],
    );
  }
}
