import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api/cart_api.dart';
import '../cart_notifier.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';




class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  double get total => cartItems.fold(0, (sum, item) {
    final prixPromo = (item['prix_promo'] as num?)?.toDouble();
    final prix = (item['prix'] ?? 0) as num;
    final quantite = (item['quantite'] ?? 1) as int;
    if (prixPromo != null && prixPromo > 0 && prixPromo < prix) {
      return sum + prixPromo * quantite;
    }
    return sum + prix.toDouble() * quantite;
  });

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

    // Mettre à jour le compteur global du panier
    cartUpdateNotifier.value = cartItems.fold<int>(0, (sum, item) => sum + (item['quantite'] ?? 1) as int);

    debugPrint('fetchCart: cartItems in state = ' + cartItems.toString());
  }

  Future<void> incrementQuantity(int index) async {
    setState(() { cartItems[index]['quantite'] += 1; });
    debugPrint('incrementQuantity: id_produit=${cartItems[index]['id_produit']}, quantite=${cartItems[index]['quantite']}');
    final result = await updateCartQuantity(cartItems[index]['id_produit'].toString(), cartItems[index]['quantite']);
    debugPrint('incrementQuantity: updateCartQuantity result = $result');

    // ⚠️ IMPORTANT : Mettre à jour le compteur global du panier
    cartUpdateNotifier.value = cartItems.fold<int>(0, (sum, item) => sum + (item['quantite'] ?? 1) as int);

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
      // Retirer l'item de la liste locale
      setState(() { cartItems.removeAt(index); });
    }

    // ⚠️ IMPORTANT : Mettre à jour le compteur global du panier
    cartUpdateNotifier.value = cartItems.fold<int>(0, (sum, item) => sum + (item['quantite'] ?? 1) as int);

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
          final prixPromo = (item['prix_promo'] as num?)?.toDouble();
          final prix = (item['prix'] ?? 0) as num;
          final isPromo = prixPromo != null && prixPromo > 0 && prixPromo < prix;
          return ListTile(
            leading: Image.network(item['image'] as String, width: 60, height: 60, fit: BoxFit.cover),
            title: Text(item['nom'] as String),
            subtitle: isPromo
                ? Row(
              children: [
                Text(
                  prix % 1 == 0
                      ? '${prix.toInt()} €'
                      : '${prix.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  prixPromo % 1 == 0
                      ? '${prixPromo.toInt()} €'
                      : '${prixPromo.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
                : Text('Prix : '
                    + (prix % 1 == 0
                        ? '${prix.toInt()} €'
                        : '${prix.toStringAsFixed(2)} €')),
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
              // Navigation vers la fiche produit (hérite de ProductsScreen)
              final product = ProductModel.fromJson(item);
              Navigator.pushNamed(
                context,
                productDetailsScreenRoute,
                arguments: product,
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
          children: [
            Text(
              'Total :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 12), // Décale le prix plus à gauche
            Text(
              '${total.toStringAsFixed(2)} €',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(), // Pousse le bouton à droite
            SizedBox(
              width: 160, // Augmente la taille du bouton Commander
              child: ElevatedButton(
                onPressed: () {
                  if (cartItems.isEmpty) return;
                  Navigator.of(context).pushNamed(orderDetailsScreenRoute);
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