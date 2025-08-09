import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_blog_model.dart';

class AdminBlogService {
  static Future<List<Blog>> getAllBlogs() async {
    final res = await http.get(Uri.parse('${AppConfig.adminBlog}'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List blogs = data is List ? data : data['blogs'] ?? data['data'] ?? [];
      return blogs.map((e) => Blog.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải blog: ${res.body}');
    }
  }

  static Future<bool> createBlog(Blog blog) async {
    final res = await http.post(
      Uri.parse('${AppConfig.adminBlog}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(blog.toJson()),
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  static Future<bool> updateBlog(String id, Blog blog) async {
    final res = await http.put(
      Uri.parse('${AppConfig.adminBlog}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(blog.toJson()),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteBlog(String id) async {
    final res = await http.delete(
      Uri.parse('${AppConfig.adminBlog}/$id'),
    );
    return res.statusCode == 200;
  }

  static Future<String> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.adminBlog}/upload-image'),
    );
    request.files.add(await http.MultipartFile.fromPath('my_file', imageFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final decoded = jsonDecode(resData);
      return decoded['url'] ?? decoded['secure_url'];
    } else {
      throw Exception('Lỗi upload ảnh blog');
    }
  }
}
