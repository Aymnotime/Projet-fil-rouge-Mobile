import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/api/cart_api.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  final ProductModel product;

  const ProductBuyNowScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductBuyNowScreen> createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int quantity = 1;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double unitPrice = (widget.product.prix_promo ?? widget.product.price).toDouble();
    double totalPrice = unitPrice * quantity;
    // Formatage du prix total : pas de décimales si entier
    String totalPriceStr = totalPrice % 1 == 0 ? totalPrice.toInt().toString() : totalPrice.toStringAsFixed(2);

    return Scaffold(
      bottomNavigationBar: CartButton(
        price: double.parse(totalPriceStr.replaceAll(',', '.')),
        title: "Ajouter au panier",
        subTitle: "Prix total",
        // Affichage du prix total formaté dans le bouton
        // On affiche le prix formaté dans le titre si besoin
        press: () async {
          debugPrint('ProductBuyNowScreen: Ajout au panier id=${widget.product.id}, quantity=$quantity');
          final result = await addToCart({
            'id': widget.product.id, // Pour compatibilité avec la fonction Flutter
            'quantity': quantity,
          });
          debugPrint('ProductBuyNowScreen: Résultat addToCart = $result');
          if (result == null) {
            // Succès
            customModalBottomSheet(
              context,
              isDismissible: false,
              child: const AddedToCartMessageScreen(),
            );
          } else {
            // Erreur
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Expanded(
                  child: Text(
                    widget.product.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Action bookmark (à définir ou supprimer)
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/Bookmark.svg",
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: NetworkImageWithLoader(widget.product.image),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: widget.product.price,
                            prixPromo: widget.product.prix_promo,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: quantity,
                          onIncrement: incrementQuantity,
                          onDecrement: decrementQuantity,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                // Tu peux ajouter d'autres sections spécifiques high-tech ici si besoin
                const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
