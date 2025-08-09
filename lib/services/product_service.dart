import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/product_model.dart';

class ProductService {
  final String baseUrl = AppConfig.products;

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/get'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Product> fetchProductDetail(String id) async {
    final url = '$baseUrl/get/$id';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Product.fromJson(data['data']);
    } else {
      throw Exception('Failed to load product detail: ${response.statusCode} - ${response.body}');
    }
  }
}