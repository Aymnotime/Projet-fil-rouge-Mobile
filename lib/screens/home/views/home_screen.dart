import 'package:shop/models/product_model.dart';
import 'package:shop/services/api/product_api.dart';
import 'package:flutter/material.dart';

import 'package:shop/components/Banner/home/banner_1.dart';
import 'package:shop/components/Banner/home/banner_2.dart';
import 'package:shop/components/Banner/M/banner_m_style_1.dart';
import 'package:shop/components/product/product_card.dart';

import 'package:shop/route/route_constants.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Récupérer la liste des produits depuis votre source (API, Provider, etc.)
    // Ici, on suppose que vous avez une méthode fetchStockItems() qui retourne la liste des produits.
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<ProductModel>>(
          future: fetchStockItems().then((items) => items.map((item) => ProductModel.fromJson(item)).toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Aucun produit'));
            }
            final products = snapshot.data!;
            return CustomScrollView(
              slivers: [
                // Banner tout en haut
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: BannerMStyle1(
                      text: "Découvrez nos nouveautés et offres !",
                      press: () {},
                    ),
                  ),
                ),
                // Carrousel Best Sellers
                SliverToBoxAdapter(
                  child: _buildCarouselSection(
                    context,
                    title: "Best Sellers",
                    products: products.where((p) => p.isBestSeller == true).toList(),
                  ),
                ),
                // Bannière après Best Sellers
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: BannerSStyle1(
                      title: "Nos Sélections",
                      subtitle: "Produits recommandés",
                      discountParcent: 20,
                      press: () {},
                    ),
                  ),
                ),
                // Carrousel Nouveautés
                SliverToBoxAdapter(
                  child: _buildCarouselSection(
                    context,
                    title: "Nouveautés",
                    products: products.where((p) => p.isNew == true).toList(),
                  ),
                ),
                // Carrousel Populaires
                SliverToBoxAdapter(
                  child: _buildCarouselSection(
                    context,
                    title: "Populaires",
                    products: products.where((p) => p.isPopular == true).toList(),
                  ),
                ),
                // Bannière après Populaires
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: BannerSStyle5(
                      title: "PROMO\n",
                      subtitle: "-50%",
                      bottomText: "Collection".toUpperCase(),
                      press: () {},
                    ),
                  ),
                ),
                // Carrousel Offres spéciales
                SliverToBoxAdapter(
                  child: _buildCarouselSection(
                    context,
                    title: "Offres spéciales",
                    products: products.where((p) => p.isFlashSale == true).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarouselSection(BuildContext context, {required String title, required List<ProductModel> products}) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: index == products.length - 1 ? 16 : 0,
              ),
              child: ProductCard(
                image: products[index].image,
                title: products[index].title,
                brandName: products[index].brandName,
                prixPromo: products[index].prix_promo,
                price: products[index].price,
                categorie: products[index].categorie,
                press: () {
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
                    arguments: products[index],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}