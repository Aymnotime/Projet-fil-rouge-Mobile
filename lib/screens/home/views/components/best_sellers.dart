import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/auth_service.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class BestSellers extends StatelessWidget {
  const BestSellers({
    super.key,
  });

  Future<List<ProductModel>> fetchBestSellers() async {
    final items = await fetchStockItems();
    // Filtrer les produits best sellers (isBestSeller == true ou == 1)
    final bestSellerItems = items.where((item) =>
    item['isBestSeller'] == true || item['isBestSeller'] == 1
    ).take(6).toList();
    debugPrint('Best sellers trouvés: \\${bestSellerItems.length}');
    return bestSellerItems
        .map((item) => ProductModel.fromJson(item))
        .toList();
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
            "Best sellers",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<ProductModel>>(
            future: fetchBestSellers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
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
                      Navigator.pushNamed(context, productDetailsScreenRoute,
                          arguments: products[index]);
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
