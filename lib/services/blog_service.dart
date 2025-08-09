import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class BlogService {
  final String baseUrl = AppConfig.adminBlog;

  Future<List<Map<String, dynamic>>> fetchBlogs() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load blogs');
    }
  }
} 