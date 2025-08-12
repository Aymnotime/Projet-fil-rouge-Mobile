import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/screens/search/views/components/search_form.dart';
import 'package:shop/services/api/product_api.dart';
import 'package:flutter/foundation.dart';
import '../../../route/route_constants.dart';
import 'components/expansion_category.dart';

String normalizeCategory(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[àâä]'), 'a')
      .replaceAll(RegExp(r'[îï]'), 'i')
      .replaceAll(RegExp(r'[ôö]'), 'o')
      .replaceAll(RegExp(r'[ûü]'), 'u')
      .replaceAll(RegExp(r'[ç]'), 'c')
      .trim();
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  Future<List<String>> fetchCategoriesFromProducts() async {
    final items = await fetchStockItems();
    final Set<String> cats = {};
    for (final p in items) {
      if (p['categorie'] != null && p['categorie'].toString().isNotEmpty) {
        final splitCats = p['categorie'].toString().split(RegExp(r'[;,]')).map((e) => e.trim()).where((e) => e.isNotEmpty);
        cats.addAll(splitCats);
      }
    }
    return cats.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Découvrir",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Explorez toutes les catégories et trouvez ce qui vous inspire !",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: SearchForm(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: Text(
                "Categories",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: fetchCategoriesFromProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune catégorie trouvée'));
                  }
                  final categories = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 22,
                      crossAxisSpacing: 22,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final catOriginal = categories[index];
                      final cat = normalizeCategory(catOriginal);
                      String? imageAsset;
                      if (cat.contains('moniteur') || cat.contains('ecran')) {
                        imageAsset = 'assets/images/ecran_category.png';
                      } else if (cat.contains('ordinateur') || cat.contains('pc portable')) {
                        imageAsset = 'assets/images/pc_category.png';
                      } else if (cat.contains('smartphone')) {
                        imageAsset = 'assets/images/smartphone_category.png';
                      } else if (cat.contains('vr') || cat.contains('casque')) {
                        imageAsset = 'assets/images/vr_category.png';
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            productsScreenRoute,
                            arguments: {
                              'category': catOriginal,
                            },
                          );
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // padding vertical réduit
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (imageAsset != null)
                                  Image.asset(
                                    imageAsset,
                                    height: 100, // taille réduite
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                const SizedBox(height: 12), // espacement réduit
                                Text(
                                  catOriginal,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}