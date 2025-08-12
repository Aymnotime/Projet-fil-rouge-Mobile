import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../network.dart';
// Récupérer les infos utilisateur (centralisé ici pour l'adresse)
Future<Map<String, dynamic>?> fetchUserInfo() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/user',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return data['user'];
    }
    return null;
  } catch (e) {
    debugPrint('Erreur lors de la récupération des infos utilisateur: $e');
    return null;
  }
}

Future<List<Map<String, dynamic>>> fetchUserAddresses() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/adresses',
      options: Options(contentType: Headers.jsonContentType),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List items = response.data['adresses'];
      return items.cast<Map<String, dynamic>>();
    }
  } catch (e) {
    debugPrint('Erreur lors de la récupération des adresses: $e');
  }
  return [];
}

Future<String?> addUserAddress(Map<String, dynamic> addressData) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/adresses',
      data: addressData,
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de l'ajout de l'adresse";
    }
  } catch (e) {
    return 'Erreur ajout adresse : $e';
  }
}

Future<String?> updateUserAddress(String addressId, Map<String, dynamic> addressData) async {
  try {
    final response = await dio.put(
      'http://10.0.2.2:3000/api/adresses/$addressId',
      data: addressData,
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la modification de l'adresse";
    }
  } catch (e) {
    return 'Erreur modification adresse : $e';
  }
}

Future<String?> deleteUserAddress(String addressId) async {
  try {
    final response = await dio.delete(
      'http://10.0.2.2:3000/api/adresses/$addressId',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la suppression de l'adresse";
    }
  } catch (e) {
    return 'Erreur suppression adresse : $e';
  }
}

Future<String?> setDefaultAddress(String addressId) async {
  try {
    final response = await dio.put(
      'http://10.0.2.2:3000/api/adresses/$addressId/defaut',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la définition de l'adresse par défaut";
    }
  } catch (e) {
    return 'Erreur définition adresse par défaut : $e';
  }
}
