import 'package:flutter/foundation.dart';
import '../network.dart';
import 'package:dio/dio.dart';
Future<String?> addToCart(Map<String, dynamic> product) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/panier',
      data: {
        'id_produit': product['id'],
        'quantite': product['quantity'] ?? 1,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de l'ajout au panier";
    }
  } catch (e) {
    return 'Erreur ajout panier : $e';
  }
}

Future<List<Map<String, dynamic>>> fetchCartItems() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/panier',
      options: Options(contentType: Headers.jsonContentType),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List items = response.data['panier'];
      return items.map<Map<String, dynamic>>((item) {
        final map = Map<String, dynamic>.from(item);
        if (map['prix_promo'] != null) {
          if (map['prix_promo'] is num) {
            map['prix_promo'] = (map['prix_promo'] as num).toDouble();
          } else if (map['prix_promo'] is String) {
            map['prix_promo'] = double.tryParse(map['prix_promo']) ?? null;
          }
        }
        return map;
      }).toList();
    }
  } catch (e) {
    debugPrint('Erreur réseau fetchCartItems: $e');
  }
  return [];
}

Future<String?> removeFromCart(String productId) async {
  try {
    final response = await dio.delete(
      'http://10.0.2.2:3000/api/panier/$productId',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la suppression du panier";
    }
  } catch (e) {
    return 'Erreur suppression panier : $e';
  }
}

Future<String?> updateCartQuantity(String productId, int quantite) async {
  try {
    final response = await dio.put(
      'http://10.0.2.2:3000/api/panier/$productId',
      data: {'quantite': quantite},
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la modification de la quantité";
    }
  } catch (e) {
    return 'Erreur modification quantité : $e';
  }
}

Future<void> emptyCart() async {
  try {
    final response = await dio.delete(
      'http://10.0.2.2:3000/api/panier',
      options: Options(contentType: Headers.jsonContentType),
    );
    if (response.statusCode != 200 || (response.data is Map && response.data['success'] != true)) {
      throw Exception(response.data['message'] ?? "Erreur lors du vidage du panier");
    }
  } catch (e) {
    throw Exception('Erreur lors du vidage du panier : $e');
  }
}
