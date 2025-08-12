import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../network.dart'; // dio partagé

Future<List<Map<String, dynamic>>> fetchUserCards() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/cartes',
      options: Options(contentType: Headers.jsonContentType),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List cartes = response.data['cartes'] ?? response.data['cards'] ?? response.data['data'] ?? [];
      return cartes.cast<Map<String, dynamic>>();
    }
  } catch (e) {
    debugPrint('Erreur lors de la récupération des cartes: $e');
  }
  return [];
}

Future<String?> addUserCard(Map<String, dynamic> cardData) async {
  try {
    final dataToSend = Map<String, dynamic>.from(cardData)..remove('brand');
    final response = await dio.post(
      'http://10.0.2.2:3000/api/cartes',
      data: dataToSend,
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de l'ajout de la carte";
    }
  } catch (e) {
    return 'Erreur ajout carte : $e';
  }
}

Future<String?> deleteUserCard(int cardId) async {
  try {
    final response = await dio.delete(
      'http://10.0.2.2:3000/api/cartes/$cardId',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la suppression de la carte";
    }
  } catch (e) {
    return 'Erreur suppression carte : $e';
  }
}

Future<String?> setDefaultCard(int cardId) async {
  try {
    final response = await dio.put(
      'http://10.0.2.2:3000/api/cartes/$cardId/defaut',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la définition de la carte par défaut";
    }
  } catch (e) {
    return 'Erreur définition carte par défaut : $e';
  }
}
