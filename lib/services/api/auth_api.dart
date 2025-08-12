import 'package:dio/dio.dart';
import '../network.dart';
// On utilise le dio et cookieJar partagés depuis network.dart

Future<String?> resetPasswordWithToken(String token, String newPassword) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/reset-password/$token',
      data: {'newPassword': newPassword},
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null; // Succès
    } else {
      return data['message'] ?? "Erreur lors de la réinitialisation du mot de passe";
    }
  } catch (e) {
    return 'Erreur lors de la réinitialisation du mot de passe : $e';
  }
}


Future<String?> registerUser(String nom, String prenom, String email, String password, String confirm) async {
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
      return null;
    } else {
      return data['message'] ?? "Erreur inconnue (code ${response.statusCode})";
    }
  } catch (e) {
    return 'Erreur d’inscription : $e';
  }
}

Future<String?> loginUser(String email, String password) async {
  try {
    await cookieJar.deleteAll(); // cookieJar vient de network.dart
    final response = await dio.post(
      'http://10.0.2.2:3000/api/login',
      data: {'email': email, 'password': password},
      options: Options(
        contentType: Headers.jsonContentType,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      // Pas besoin de saveFromResponse, CookieManager le fait automatiquement
      return null;
    } else {
      return data['message'] ?? 'Erreur inconnue (code ${response.statusCode})';
    }
  } catch (e) {
    return 'Erreur de connexion : $e';
  }
}

Future<String?> logoutUser() async {
  try {
    final response = await dio.get(
      'http://10.0.2.2:3000/api/logout',
      options: Options(contentType: Headers.jsonContentType),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      await cookieJar.deleteAll();
      return null;
    } else {
      return response.data['message'] ?? "Erreur lors de la déconnexion";
    }
  } catch (e) {
    return 'Erreur de déconnexion : $e';
  }
}

Future<String?> sendPasswordResetEmail(String email) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/forgot-password',
      data: {'email': email},
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? 'Erreur lors de l\'envoi du mail';
    }
  } catch (e) {
    return 'Erreur lors de l\'envoi du mail : $e';
  }
}

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
    return null;
  }
}

Future<String?> updateUserInfo(Map<String, dynamic> updateData) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/user',
      data: updateData,
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la mise à jour";
    }
  } catch (e) {
    return 'Erreur de mise à jour : $e';
  }
}

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
      return null;
    } else {
      return data['message'] ?? "Erreur lors de la mise à jour du mot de passe";
    }
  } catch (e) {
    return 'Erreur de mise à jour du mot de passe : $e';
  }
}
