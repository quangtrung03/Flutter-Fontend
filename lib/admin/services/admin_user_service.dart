import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_user_model.dart';

class AdminUserService {
  // Lấy danh sách tất cả user
  static Future<List<User>> getAllUsers() async {
    final res = await http.get(Uri.parse(AppConfig.adminUsers));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => User.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['users'] ?? [];
        if (list is List) {
          return list.map((e) => User.fromJson(e)).toList();
        }
      }
    } else {
      throw Exception('Lỗi tải danh sách user: ${res.body}');
    }
    return [];
  }

  // Lấy thông tin user theo ID
  static Future<User?> getUserById(String id) async {
    final res = await http.get(Uri.parse('${AppConfig.adminUsers}/$id'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data')) return User.fromJson(data['data']);
        if (data.containsKey('user')) return User.fromJson(data['user']);
        return User.fromJson(data);
      }
    }
    return null;
  }

  // Tạo user mới
  static Future<bool> createUser(User user) async {
    final res = await http.post(
      Uri.parse(AppConfig.adminUsers),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Cập nhật thông tin user
  static Future<bool> updateUser(String id, User user) async {
    final res = await http.put(
      Uri.parse('${AppConfig.adminUsers}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    return res.statusCode == 200;
  }

  // Xóa user
  static Future<bool> deleteUser(String id) async {
    final res = await http.delete(Uri.parse('${AppConfig.adminUsers}/$id'));
    return res.statusCode == 200;
  }

  // Block/Unblock user
  static Future<bool> toggleUserStatus(String id, bool isActive) async {
    final res = await http.patch(
      Uri.parse('${AppConfig.adminUsers}/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isActive': isActive}),
    );
    return res.statusCode == 200;
  }

  // Tìm kiếm user
  static Future<List<User>> searchUsers(String query) async {
    final res = await http.get(
      Uri.parse('${AppConfig.adminUsers}/search?q=${Uri.encodeComponent(query)}')
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => User.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['users'] ?? [];
        if (list is List) {
          return list.map((e) => User.fromJson(e)).toList();
        }
      }
    }
    return [];
  }

  // Lấy thống kê user
  static Future<Map<String, dynamic>> getUserStats() async {
    final res = await http.get(Uri.parse('${AppConfig.adminUsers}/stats'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : {};
    }
    return {};
  }

  // Reset password user
  static Future<bool> resetUserPassword(String id, String newPassword) async {
    final res = await http.patch(
      Uri.parse('${AppConfig.adminUsers}/$id/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newPassword': newPassword}),
    );
    return res.statusCode == 200;
  }

  // Lấy lịch sử đơn hàng của user
  static Future<List<dynamic>> getUserOrderHistory(String userId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.adminUsers}/$userId/orders')
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        return data['data'] ?? data['orders'] ?? [];
      }
    }
    return [];
  }
}
