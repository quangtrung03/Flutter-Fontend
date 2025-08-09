import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class PayPalService {
  static Future<String?> createPayPalPayment({
    required double amount,
    required String currency,
    required String description,
    String? orderId,
  }) async {
    final url = '${AppConfig.payment}/paypal/create';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'description': description,
          'orderId': orderId, // ✅ Thêm orderId để liên kết
        }),
      );
      
      print('🔄 PayPal create payment response: ${response.statusCode}');
      print('📱 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['approvalUrl'];
        }
      }
      return null;
    } catch (e) {
      print('PayPal service error: $e');
      return null;
    }
  }

  static Future<bool> capturePayPalPayment({
    required String paymentId,
    required String payerId,
  }) async {
    final url = '${AppConfig.payment}/paypal/capture';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentId': paymentId,
          'payerId': payerId,
        }),
      );
      
      print('🔄 PayPal capture response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('PayPal capture error: $e');
      return false;
    }
  }

  // ✅ Thêm method để update order sau khi PayPal thành công
  static Future<bool> updateOrderAfterPayment({
    required String orderId,
    required String paymentId,
    required String payerId,
  }) async {
    final url = '${AppConfig.payment}/paypal/update-order';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderId': orderId,
          'paymentId': paymentId,
          'payerId': payerId,
        }),
      );
      
      print('🔄 PayPal update order response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('PayPal update order error: $e');
      return false;
    }
  }
}
