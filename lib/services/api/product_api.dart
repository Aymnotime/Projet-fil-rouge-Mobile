import 'package:flutter/foundation.dart';
import '../network.dart';
import 'package:dio/dio.dart';

Future<List<Map<String, dynamic>>> fetchStockItems() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/produits',
      options: Options(contentType: Headers.jsonContentType),
    );
    if (response.statusCode == 200) {
      final List items = response.data;
      return items.map<Map<String, dynamic>>((e) {
        final map = Map<String, dynamic>.from(e);
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
    debugPrint('Erreur réseau fetchStockItems: $e');
  }
  return [];
}

Future<List<Map<String, dynamic>>> fetchCategoriesFromApi() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/categories',
      options: Options(contentType: Headers.jsonContentType),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List items = response.data['categories'];
      return items.cast<Map<String, dynamic>>();
    }
  } catch (e) {
    debugPrint('Erreur réseau fetchCategoriesFromApi: $e');
  }
  return [];
}
