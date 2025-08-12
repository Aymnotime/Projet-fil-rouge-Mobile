import 'package:dio/dio.dart';
import '../network.dart';
Future<Map<String, dynamic>?> placeOrderAndGetTotal() async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/commandes',
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (response.statusCode == 200 && data['success'] == true) {
      return {'id': data['id'], 'montant_total': data['montant_total']};
    }
    return null;
  } catch (_) {
    return null;
  }
}


Future<Map<String, dynamic>?> createPaymentIntent(num amount, String commandeId, {String? paymentMethodId}) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/create-payment-intent',
      data: {
        'amount': amount,
        'commande_id': commandeId,
        if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    return response.data;
  } catch (_) {
    return null;
  }
}

Future<Map<String, dynamic>?> updatePaymentStatus(String paymentIntentId, String statut, String commandeId) async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/api/update-payment-status',
      data: {
        'payment_intent_id': paymentIntentId,
        'statut': statut,
        'commande_id': commandeId,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    return response.data;
  } catch (_) {
    return null;
  }
}
