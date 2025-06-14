import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/auth_service.dart';
import '../cart_notifier.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/product_details_screen.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  double get total => cartItems.fold(0, (sum, item) => sum + ((item['prix'] ?? 0) as num).toDouble() * ((item['quantite'] ?? 1) as int));

  @override
  void initState() {
    super.initState();
    debugPrint('CartScreen: initState');
    fetchCart();
    cartUpdateNotifier.addListener(_onCartUpdate);
  }

  void _onCartUpdate() {
    fetchCart();
  }

  @override
  void dispose() {
    cartUpdateNotifier.removeListener(_onCartUpdate);
    super.dispose();
  }

  Future<void> fetchCart() async {
    setState(() { isLoading = true; });
    final items = await fetchCartItems();
    debugPrint('fetchCart: items from API = ' + items.toString());
    setState(() {
      cartItems = items;
      isLoading = false;
    });
    debugPrint('fetchCart: cartItems in state = ' + cartItems.toString());
  }

  Future<void> incrementQuantity(int index) async {
    setState(() { cartItems[index]['quantite'] += 1; });
    debugPrint('incrementQuantity: id_produit=${cartItems[index]['id_produit']}, quantite=${cartItems[index]['quantite']}');
    final result = await updateCartQuantity(cartItems[index]['id_produit'].toString(), cartItems[index]['quantite']);
    debugPrint('incrementQuantity: updateCartQuantity result = $result');
    fetchCart();
  }

  Future<void> decrementQuantity(int index) async {
    if (cartItems[index]['quantite'] > 1) {
      setState(() { cartItems[index]['quantite'] -= 1; });
      debugPrint('decrementQuantity: id_produit=${cartItems[index]['id_produit']}, quantite=${cartItems[index]['quantite']}');
      final result = await updateCartQuantity(cartItems[index]['id_produit'].toString(), cartItems[index]['quantite']);
      debugPrint('decrementQuantity: updateCartQuantity result = $result');
    } else {
      debugPrint('decrementQuantity: remove id_produit=${cartItems[index]['id_produit']}');
      final result = await removeFromCart(cartItems[index]['id_produit'].toString());
      debugPrint('decrementQuantity: removeFromCart result = $result');
    }
    fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CartScreen build: cartItems = ' + cartItems.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCart,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : ListView.separated(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: cartItems.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            leading: Image.network(item['image'] as String, width: 60, height: 60, fit: BoxFit.cover),
            title: Text(item['nom'] as String),
            subtitle: Text('Prix : \\${((item['prix'] ?? 0) as num).toDouble()} €'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => decrementQuantity(index),
                ),
                Text('${item['quantite'] ?? 1}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => incrementQuantity(index),
                ),
              ],
            ),
            onTap: () {
              // Navigation vers la fiche produit
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(
                    isProductAvailable: true,
                    products: [
                      ProductModel(
                        id: item['id_produit'].toString(),
                        image: item['image'] ?? '',
                        title: item['nom'] ?? '',
                        brandName: item['marque'] ?? '',
                        description: item['description'] ?? '',
                        price: (item['prix'] ?? 0).toDouble(),
                        categorie: item['categorie'] ?? '',
                        priceAfterDiscount: item['prix_apres_remise'] != null ? (item['prix_apres_remise'] as num).toDouble() : null,
                        discountPercent: item['discountPercent'] as int?,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${total.toStringAsFixed(2)} €',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Action de validation du panier (ex: envoyer à /api/commande)
                },
                child: const Text('Commander'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}