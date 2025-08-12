import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class ProductsSection extends StatelessWidget {
  final List<Map<String, dynamic>> cartProducts;
  final Function(String?) onSelectProduct;
  final Future<void> Function(dynamic) onRemoveFromCart;

  const ProductsSection({
    super.key,
    required this.cartProducts,
    required this.onSelectProduct,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.only(bottom: defaultPadding),
      color: Colors.white,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: primaryColor, size: 30),
                const SizedBox(width: 14),
                const Text('Produits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 14),
            if (cartProducts.isEmpty)
              const Text('Votre panier est vide.', style: TextStyle(color: Colors.grey)),
            ...cartProducts.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () => onSelectProduct(p['id']?.toString()),
                child: Row(
                  children: [
                    if (p['image'] != null && p['image'].toString().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          p['image'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, size: 22, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, size: 22, color: Colors.grey),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(p['nom'] ?? '', style: const TextStyle(fontSize: 15)),
                    ),
                    Text('x${p['quantity'] ?? p['quantite'] ?? 1}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 10),
                    Text('${p['prix']} €', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async => await onRemoveFromCart(p['id']),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
