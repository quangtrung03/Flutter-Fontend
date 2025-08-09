
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'rememberMe': rememberMe,
        }),
      );
      final data = json.decode(response.body);
      // Nếu có token và user data, lưu vào SharedPreferences
      if (data['token'] != null && data['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', json.encode(data['user']));
      }
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi đăng nhập: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userName': name,
          'email': email,
          'password': password,
        }),
      );
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi đăng ký:  [${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      // Xóa token và user data khỏi SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi đăng xuất: ${e.toString()}'
      };
    }
  }

  // Optional: Lấy thông tin user hiện tại nếu có token
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'success': false, 'message': 'Chưa đăng nhập'};
      }
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể lấy thông tin user: ${e.toString()}'
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Lấy token từ SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Lấy user data đã lưu từ SharedPreferences
  Future<Map<String, dynamic>?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUser(String id, String name, String email, String? avatar) async {
    final response = await http.put(
      Uri.parse('${AppConfig.adminUsers}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userName': name,
        'email': email,
        'avatar': avatar,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> changePassword(String id, String newPassword) async {
    final response = await http.put(
      Uri.parse('${AppConfig.adminUsers}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'password': newPassword,
      }),
    );
    return response.statusCode == 200;
  }
} 