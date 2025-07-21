import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';  // <-- import du modèle
import 'package:shop/route/route_constants.dart';

import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import 'components/notify_me_card.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

import 'package:shop/services/auth_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final bool isProductAvailable;
  final ProductModel currentProduct;

  const ProductDetailsScreen({
    super.key,
    this.isProductAvailable = true,
    required this.currentProduct,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  List<ProductModel> allProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final List<Map<String, dynamic>> apiProducts = await fetchStockItems();
    setState(() {
      allProducts = apiProducts.map((e) => ProductModel.fromJson(e)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProductModel currentProduct = widget.currentProduct;

    // Filtrer les produits similaires par catégorie (hors produit courant)
    final String? currentCategorie = currentProduct.categorie;
    final List<ProductModel> similarProducts = allProducts
        .where((p) =>
    p.id != currentProduct.id &&
        p.categorie != null &&
        currentCategorie != null &&
        p.categorie!.trim().toLowerCase() == currentCategorie.trim().toLowerCase())
        .take(6)
        .toList();

    return Scaffold(
      bottomNavigationBar: widget.isProductAvailable
          ? CartButton(
        price: currentProduct.displayPrice,
        press: () async {
          customModalBottomSheet(
            context,
            height: MediaQuery.of(context).size.height * 0.92,
            child: ProductBuyNowScreen(product: currentProduct),
          );
          return;
        },
      )
          : NotifyMeCard(
        isNotify: false,
        onChanged: (value) {},
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.bookmark_border,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Image.network(
                          currentProduct.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (currentProduct.categorie != null && currentProduct.categorie!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        currentProduct.categorie!.split(',').map((e) => e.trim()).join(', '),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 13, color: Colors.blueGrey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (currentProduct.isPromo) ...[
                      Text(
                        '${currentProduct.price.toStringAsFixed(2)} €',
                        style: TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currentProduct.displayPrice.toStringAsFixed(2)} €',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '${currentProduct.displayPrice.toStringAsFixed(2)} €',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ProductInfo(
              brand: currentProduct.brandName,
              title: currentProduct.title,
              isAvailable: widget.isProductAvailable,
              description: currentProduct.description,
              rating: 4.4,
              numOfReviews: 126,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Retourner",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: 4.3,
                  numOfReviews: 128,
                  numOfFiveStar: 80,
                  numOfFourStar: 30,
                  numOfThreeStar: 5,
                  numOfTwoStar: 4,
                  numOfOneStar: 1,
                ),
              ),
            ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Avis",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(
                  context,
                  productReviewsScreenRoute,
                  arguments: currentProduct,
                );
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "Produits similaires",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            if (similarProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: similarProducts.length,
                    itemBuilder: (context, index) {
                      final product = similarProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: defaultPadding,
                          right: index == similarProducts.length - 1 ? defaultPadding : 0,
                        ),
                        child: ProductCard(
                          image: product.image,
                          title: product.title,
                          brandName: product.brandName,
                          // Affichage prix promo sur la card
                          price: product.prix_promo ?? product.price,
                          categorie: product.categorie,
                          press: () {
                            // Action sur produit recommandé
                          },
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            ),
          ],
        ),
      ),
    );
  }
}

