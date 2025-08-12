



import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api/order_api.dart';
import 'package:shop/services/api/product_api.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders(); // Utilise maintenant le service centralisé
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mes commandes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur : b[1m${snapshot.error}[0m'));
            }
            final orders = snapshot.data ?? [];
            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/Order.svg",
                      height: 80,
                      colorFilter: ColorFilter.mode(
                        Colors.grey.withOpacity(0.2),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Text(
                      "Aucune commande trouvée",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: defaultPadding),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final date = order['date'] ?? order['date_commande'] ?? '';
    final id = order['id']?.toString() ?? '';
    final total = order['montant_total'] ?? order['total'] ?? order['prix_total'] ?? '';
    final status = order['statut'] ?? order['status'] ?? 'En attente';

    final isDelivered = status == 'Livrée';
    final isPending = status.toLowerCase().contains('attente') || status.toLowerCase().contains('pending');
    final badgeColor = isDelivered
        ? Colors.green.shade100
        : isPending
        ? Colors.blue.shade100
        : Colors.orange.shade100;
    final badgeTextColor = isDelivered
        ? Colors.green
        : isPending
        ? Colors.blue.shade700
        : Colors.orange;
    final badgeText = isDelivered
        ? 'Livrée'
        : isPending
        ? 'En attente'
        : status;

    // Extraction des produits commandés (toujours une List<Map<String, dynamic>> après parsing dans fetchOrders)
    List<dynamic> produits = [];
    dynamic produitsRaw = order['produits'];
    if (produitsRaw is List) {
      produits = produitsRaw;
    } else if (produitsRaw is String) {
      try {
        final decoded = produitsRaw.isNotEmpty ? jsonDecode(produitsRaw) : [];
        if (decoded is List) {
          produits = decoded;
        } else if (decoded is Map) {
          produits = [decoded];
        }
      } catch (e) {
        produits = [];
      }
    } else if (produitsRaw is Map) {
      produits = [produitsRaw];
    }
    // Force le mapping en Map<String, dynamic> pour chaque produit
    produits = produits.map((p) {
      if (p is Map<String, dynamic>) return p;
      if (p is String) {
        try {
          final decoded = jsonDecode(p);
          if (decoded is Map<String, dynamic>) return decoded;
        } catch (_) {}
      }
      return <String, dynamic>{};
    }).toList();
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: defaultPadding),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDelivered
            ? BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône, badge et numéro commande
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? Colors.green.withOpacity(0.1)
                          : primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Order.svg",
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        isDelivered ? Colors.green : primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Commande #$id",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Date : $date",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: badgeTextColor.withOpacity(0.18),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: badgeTextColor.withOpacity(0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badgeText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              // Bloc infos commande
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          "${total.toString()} €",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (produits.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        "Produits commandés :",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 6),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: produits.length,
                        separatorBuilder: (_, __) => const Divider(height: 16, color: Colors.transparent),
                        itemBuilder: (context, idx) {
                          final p = produits[idx];
                          final nom = p['nom'] ?? '';
                          final qte = p['quantity'] ?? p['quantite'] ?? 1;
                          // Cast prix et prix_promo en num si besoin
                          num? prixNum = p['prix'] is num ? p['prix'] : num.tryParse(p['prix']?.toString() ?? '');
                          num? prixPromoNum = p['prix_promo'] is num ? p['prix_promo'] : num.tryParse(p['prix_promo']?.toString() ?? '');
                          final prix = (prixPromoNum != null && prixPromoNum > 0 && prixNum != null && prixPromoNum < prixNum)
                              ? prixPromoNum
                              : prixNum ?? '';
                          String? imageUrl = p['image']?.toString();
                          // Les URLs sont déjà absolues, aucune modification nécessaire
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              if (p['id'] != null) {
                                // On va chercher les infos complètes du produit pour la fiche
                                try {
                                  // On suppose que fetchStockItems() existe et retourne tous les produits
                                  final allProducts = await fetchStockItems();
                                  final prod = allProducts.firstWhere(
                                        (item) => item['id'].toString() == p['id'].toString(),
                                    orElse: () => <String, dynamic>{},
                                  );
                                  if (prod.isNotEmpty) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => FractionallySizedBox(
                                        heightFactor: 0.98,
                                        child: ProductDetailsScreen(currentProduct: ProductModel.fromJson(prod)),
                                      ),
                                    );
                                  }
                                } catch (_) {}
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (imageUrl != null && imageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl,
                                        width: 54,
                                        height: 54,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 54,
                                          height: 54,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image_not_supported, size: 22, color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.image, size: 22, color: Colors.grey),
                                    ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      "$nom",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "x$qte",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "${prix.toString()} €",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
