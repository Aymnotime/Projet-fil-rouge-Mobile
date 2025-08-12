import 'package:dio/dio.dart';
import '../network.dart';

class SendMailApi {
  // Utilise le Dio partagé configuré dans network.dart


  /// Envoie le mail de bienvenue via l’API backend
  static Future<bool> sendWelcomeMail({required int userId}) async {
    try {
      final response = await dio.post(
        'http://10.0.2.2:3000/api/send-welcome-mail',
        data: {
          'userId': userId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data['success'] == true;
    } catch (e) {
      print('Erreur envoi mail bienvenue: $e');
      return false;
    }
  }
}
