
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../network.dart'; // dio partagé

Future<String?> placeOrder({
  required dynamic addressId,
  required dynamic cardId,
  required List<Map<String, dynamic>> products,
}) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/commandes',
      data: {
        'id_adresse': addressId,
        'id_carte': cardId,
        'produits': products,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la commande";
    }
  } catch (e) {
    return 'Erreur lors de la commande : $e';
  }
}

Future<List<Map<String, dynamic>>> fetchOrders() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/commandes',
      options: Options(contentType: Headers.jsonContentType),
    );
    List<Map<String, dynamic>> commandes = [];
    if (response.statusCode == 200 && response.data is List) {
      commandes = List<Map<String, dynamic>>.from(response.data);
    } else if (response.data is Map && response.data['success'] == true && response.data['commandes'] != null) {
      commandes = List<Map<String, dynamic>>.from(response.data['commandes']);
    }
    for (final commande in commandes) {
      final produits = commande['produits'];
      if (produits is String) {
        try {
          final decoded = jsonDecode(produits);
          if (decoded is List) {
            commande['produits'] = List<Map<String, dynamic>>.from(decoded);
          } else if (decoded is Map) {
            commande['produits'] = [Map<String, dynamic>.from(decoded)];
          } else {
            commande['produits'] = [];
          }
        } catch (e) {
          commande['produits'] = [];
        }
      } else if (produits is Map) {
        commande['produits'] = [Map<String, dynamic>.from(produits)];
      } else if (produits is List) {
        commande['produits'] = List<Map<String, dynamic>>.from(produits);
      } else {
        commande['produits'] = [];
      }
    }
    return commandes;
  } catch (e) {
    debugPrint('Erreur lors de la récupération des commandes: $e');
  }
  return [];
}
