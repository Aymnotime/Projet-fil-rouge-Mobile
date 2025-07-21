import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/screens/search/views/components/search_form.dart';
import 'package:shop/services/auth_service.dart';

import 'components/expansion_category.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  Future<List<CategoryModel>> fetchCategories() async {
    // Utilise la fonction dynamique (API)
    final items = await fetchCategoriesFromApi();
    return items.map<CategoryModel>((item) => CategoryModel.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: FutureBuilder<List<CategoryModel>>(
                future: fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune catégorie trouvée'));
                  }
                  final categories = snapshot.data!;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) => ExpansionCategory(
                      svgSrc: categories[index].svgSrc ?? '',
                      title: categories[index].title,
                      subCategory: categories[index].subCategories ?? [],
                    ),
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
