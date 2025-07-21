import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

final dio = Dio();
late PersistCookieJar cookieJar;

// Configurer Dio avec PersistCookieJar (à appeler une fois au démarrage)
Future<void> setupDio() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final cookiePath = '${appDocDir.path}/.cookies/';

  // Créer le dossier s'il n'existe pas
  final cookieDir = Directory(cookiePath);
  if (!await cookieDir.exists()) {
    await cookieDir.create(recursive: true);
  }

  cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));

  dio.interceptors.clear(); // Évite les doublons si setupDio est rappelé
  dio.interceptors.add(CookieManager(cookieJar));
}

// À appeler dans main() avant runApp()
Future<void> initializeNetwork() async {
  await setupDio();
}

// Fonction pour s'inscrire
Future<String?> registerUser(
    String nom, String prenom, String email, String password, String confirm) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/register',
      data: {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
        'confirm': confirm,
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur inconnue";
    }
  } catch (e) {
    return 'Erreur d’inscription : $e';
  }
}

// Fonction pour se connecter
Future<String?> loginUser(String email, String password) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/login',
      data: {'email': email, 'password': password},
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Connexion réussie
    } else {
      return data['message'] ?? "Erreur inconnue";
    }
  } catch (e) {
    return 'Erreur de connexion : $e';
  }
}

// Récupérer l'utilisateur connecté
Future<Map<String, dynamic>?> fetchCurrentUser() async {
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
    return null;
  }
}

// Fonction pour se déconnecter
Future<String?> logoutUser() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/logout',
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      // Nettoyer les cookies côté client
      await cookieJar.deleteAll();
      return null; // Déconnexion réussie
    } else {
      return response.data['message'] ?? "Erreur lors de la déconnexion";
    }
  } catch (e) {
    return 'Erreur de déconnexion : $e';
  }
}

// Fonction pour récupérer les produits
Future<List<Map<String, dynamic>>> fetchStockItems() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/produits',
      options: Options(contentType: Headers.jsonContentType),
    );

    debugPrint('Réponse brute API: \n${response.data}');

    if (response.statusCode == 200) {
      final List items = response.data;
      debugPrint('Catégories reçues : ' + items.map((e) => e['categorie']).toList().toString());
      debugPrint('Prix promo reçus : ' + items.map((e) => e['prix_promo']).toList().toString());
      // S'assurer que prix_promo est bien casté en double ou null
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
    } else {
      debugPrint('Erreur API: \n${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Erreur réseau fetchStockItems: $e');
  }
  return [];
}

// Fonction pour ajouter un produit au panier
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

// Récupérer le panier de l'utilisateur (API)
Future<List<Map<String, dynamic>>> fetchCartItems() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/panier',
      options: Options(contentType: Headers.jsonContentType),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List items = response.data['panier'];
      // On s'assure que prix_promo est bien casté en double ou null
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

// Supprimer un produit du panier (API)
Future<String?> removeFromCart(String productId) async {
  try {
    final response = await dio.delete(
      'http://10.0.2.2:3000/api/panier/$productId',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      debugPrint('Suppression du produit $productId réussie.');
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la suppression du panier";
    }
  } catch (e) {
    return 'Erreur suppression panier : $e';
  }
}

// Modifier la quantité d'un produit dans le panier (API)
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

// Fonction pour récupérer les catégories depuis l'API
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

// Récupérer les informations de l'utilisateur connecté
Future<Map<String, dynamic>?> getUserInfo() async {
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

// Mettre à jour les informations de l'utilisateur
Future<String?> updateUserInfo(Map<String, dynamic> updateData) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/user',
      data: updateData,
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur lors de la mise à jour";
    }
  } catch (e) {
    return 'Erreur de mise à jour : $e';
  }
}

// Mettre à jour le mot de passe de l'utilisateur
Future<String?> updateUserPassword(String currentPassword, String newPassword) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/user/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur lors de la mise à jour du mot de passe";
    }
  } catch (e) {
    return 'Erreur de mise à jour du mot de passe : $e';
  }
}

// Récupérer les avis d'un produit
Future<List<Map<String, dynamic>>> fetchProductReviews(String productId) async {
  try {
    debugPrint('Récupération des avis pour le produit ID: $productId');
    final response = await dio.get(
      'http://10.0.2.2:3000/api/produits/$productId/avis',
      options: Options(contentType: Headers.jsonContentType),
    );

    debugPrint('Réponse API avis: ${response.data}');
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      final List items = data['avis'];
      debugPrint('Nombre d\'avis trouvés: ${items.length}');
      return items.cast<Map<String, dynamic>>();
    } else {
      debugPrint('Erreur API avis: ${data['message']}');
    }
  } catch (e) {
    debugPrint('Erreur réseau fetchProductReviews: $e');
  }
  return [];
}

// Ajouter un avis sur un produit
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
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur lors de l'ajout de l'avis";
    }
  } catch (e) {
    return 'Erreur ajout avis : $e';
  }
}

// --- Gestion des adresses de livraison ---

// Récupérer toutes les adresses de l'utilisateur
Future<List<Map<String, dynamic>>> fetchUserAddresses() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/adresses',
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      final List items = data['adresses'];
      return items.cast<Map<String, dynamic>>();
    }
  } catch (e) {
    debugPrint('Erreur lors de la récupération des adresses: $e');
  }
  return [];
}

// Ajouter une nouvelle adresse
Future<String?> addUserAddress(Map<String, dynamic> addressData) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/adresses',
      data: addressData,
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur lors de l'ajout de l'adresse";
    }
  } catch (e) {
    return 'Erreur ajout adresse : $e';
  }
}

// Modifier une adresse existante
Future<String?> updateUserAddress(String addressId, Map<String, dynamic> addressData) async {
  try {
    final response = await dio.put(
      'http://10.0.2.2:3000/api/adresses/$addressId',
      data: addressData,
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur lors de la modification de l'adresse";
    }
  } catch (e) {
    return 'Erreur modification adresse : $e';
  }
}

// Supprimer une adresse
Future<String?> deleteUserAddress(String addressId) async {
  try {
    final response = await dio.delete(
      'http://10.0.2.2:3000/api/adresses/$addressId',
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur lors de la suppression de l'adresse";
    }
  } catch (e) {
    return 'Erreur suppression adresse : $e';
  }
}

// Définir une adresse comme adresse par défaut
Future<String?> setDefaultAddress(String addressId) async {
  try {
    final response = await dio.put(
      'http://10.0.2.2:3000/api/adresses/$addressId/defaut',
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur lors de la définition de l'adresse par défaut";
    }
  } catch (e) {
    return 'Erreur définition adresse par défaut : $e';
  }
}
