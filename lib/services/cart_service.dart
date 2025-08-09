import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/cart_model.dart';

class CartService {
  final String baseUrl = AppConfig.cart;

  Future<Cart> fetchCart(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Cart.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load cart: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  Future<bool> addToCart(String userId, String productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': productId,
          'quantity': quantity,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromCart(String userId, String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$userId/$productId'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCart(String userId, String productId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-cart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': productId,
          'quantity': quantity,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 