import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/order_model.dart';

class OrderService {
  final String baseUrl = AppConfig.order;

  Future<List<Order>> fetchOrders(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body['data'];
        return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('fetchOrders Error: $e');
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<Order> fetchOrderDetail(String orderId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$orderId'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return Order.fromJson(body['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load order detail');
      }
    } catch (e) {
      throw Exception('Failed to load order detail: $e');
    }
  }

  Future<Map<String, dynamic>> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
} 