import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';  // <-- import du modèle

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

class ProductDetailsScreen extends StatelessWidget {
  final bool isProductAvailable;
  final List<ProductModel> products;

  const ProductDetailsScreen({
    super.key,
    this.isProductAvailable = true,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final ProductModel currentProduct = products.isNotEmpty
        ? products[0]
        : ProductModel(
      id: '', // Ajout de l'id obligatoire
      image: '',
      title: 'Produit indisponible',
      brandName: '',
      description: '',
      price: 0,
    );

    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(
        price: currentProduct.computedPriceAfterDiscount,
        press: () {
          customModalBottomSheet(
            context,
            height: MediaQuery.of(context).size.height * 0.92,
            child: ProductBuyNowScreen(product: currentProduct),
          );
        },
      )
          : NotifyMeCard(
        isNotify: false,
        onChanged: (value) {},
      ),
      body: SafeArea(
        child: CustomScrollView(
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
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.network(
                      currentProduct.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            ProductInfo(
              brand: currentProduct.brandName,
              title: currentProduct.title,
              isAvailable: isProductAvailable,
              description: currentProduct.description, // Utilisation de la description dynamique de l'API
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
                Navigator.pushNamed(context, '/productReviews');
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
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: defaultPadding,
                        right: index == products.length - 1 ? defaultPadding : 0,
                      ),
                      child: ProductCard(
                        image: product.image,
                        title: product.title,
                        brandName: product.brandName,
                        price: product.price,
                        priceAfterDiscount: product.priceAfterDiscount,
                        discountPercent: product.discountPercent,
                        press: () {
                          // Action sur produit recommandé
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            ),
          ],
        ),
      ),
    );
  }
}
