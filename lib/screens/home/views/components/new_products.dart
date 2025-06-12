import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/auth_service.dart';

import '../../../../constants.dart';

class NewProducts extends StatelessWidget {
  const NewProducts({super.key});

  Future<List<ProductModel>> fetchNewProducts() async {
    try {
      final items = await fetchStockItems();
      final popularItems = items.where((item) =>
      item['isNew'] == true || item['isNew'] == 1
      ).take(6).toList();
      return popularItems
          .map((item) => ProductModel(
        id: item['id']?.toString() ?? '',
        image: item['image'] ?? '',
        title: item['nom'] ?? '',
        description: item['description'] ?? '',
        brandName: item['brandName'] ?? '',
        price: (item['prix'] as num?)?.toDouble() ?? 0.0,
        priceAfterDiscount: item['priceAfterDiscount'] != null
            ? (item['priceAfterDiscount'] as num).toDouble()
            : null,
        discountPercent: item['discountPercent'] != null
            ? item['discountPercent'] as int
            : null,
      ))
          .toList();
    } catch (e) {
      // Affiche l'erreur dans la console
      debugPrint('Erreur fetchNewProducts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Nouveau Produit",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<ProductModel>>(
            future: fetchNewProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Erreur lors du chargement"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Aucun produit populaire"));
              }
              final products = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    left: defaultPadding,
                    right: index == products.length - 1 ? defaultPadding : 0,
                  ),
                  child: ProductCard(
                    image: products[index].image,
                    title: products[index].title,
                    brandName: products[index].brandName,
                    price: products[index].price,
                    priceAfterDiscount: products[index].priceAfterDiscount,
                    discountPercent: products[index].discountPercent,
                    press: () {
                      Navigator.pushNamed(
                        context,
                        productDetailsScreenRoute,
                        arguments: products[index],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}