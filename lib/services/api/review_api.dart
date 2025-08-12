import 'package:flutter/foundation.dart';
import '../network.dart';
import 'package:dio/dio.dart';

Future<List<Map<String, dynamic>>> fetchProductReviews(String productId) async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/produits/$productId/avis',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      final List items = data['avis'];
      return items.cast<Map<String, dynamic>>();
    }
  } catch (e) {
    debugPrint('Erreur réseau fetchProductReviews: $e');
  }
  return [];
}

Future<String?> addProductReview(String productId, int note, String? titre, String? commentaire) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/produits/$productId/avis',
      data: {
        'note': note,
        'titre': titre,
        'commentaire': commentaire,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de l'ajout de l'avis";
    }
  } catch (e) {
    return 'Erreur ajout avis : $e';
  }
}
