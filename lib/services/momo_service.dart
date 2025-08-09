import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class MomoService {
  static Future<String?> createMomoPayment({
    required int amount,
    required String orderInfo,
    required String redirectUrl,
  }) async {
    final url = '${AppConfig.payment}/momo';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': amount,
        'orderInfo': orderInfo,
        'redirectUrl': redirectUrl,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['payUrl'];
    }
    return null;
  }
} 