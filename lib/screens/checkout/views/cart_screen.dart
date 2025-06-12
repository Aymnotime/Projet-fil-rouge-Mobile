import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/auth_service.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  double get total => cartItems.fold(0, (sum, item) => sum + (item['prix'] as double) * (item['quantity'] as int));

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    setState(() { isLoading = true; });
    final items = await fetchCartItems();
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  Future<void> incrementQuantity(int index) async {
    setState(() { cartItems[index]['quantity'] += 1; });
    await addToCart(cartItems[index]);
    fetchCart();
  }

  Future<void> decrementQuantity(int index) async {
    if (cartItems[index]['quantity'] > 1) {
      setState(() { cartItems[index]['quantity'] -= 1; });
      await addToCart(cartItems[index]);
    } else {
      await removeFromCart(cartItems[index]['id'].toString());
    }
    fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        centerTitle: true,
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
            subtitle: Text('Prix : ${item['prix']} €'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => decrementQuantity(index),
                ),
                Text('${item['quantity']}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => incrementQuantity(index),
                ),
              ],
            ),
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
            ElevatedButton(
              onPressed: () {
                // Action de validation du panier (ex: envoyer à /api/commande)
              },
              child: const Text('Commander'),
            ),
          ],
        ),
      ),
    );
  }
}
