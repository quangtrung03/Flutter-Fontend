import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_service.dart';

class NotificationService {
  final AuthService _authService = AuthService();

  // Get notification settings for current user
  Future<Map<String, bool>?> getNotificationSettings() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/user/notification-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Map<String, bool>.from(data['settings'] ?? {});
        }
      }
      
      // Return default settings if not found
      return {
        'newOrder': true,
        'orderStatusUpdate': true,
        'orderDelivered': true,
        'orderCancelled': true,
        'promotions': false,
        'newProduct': false,
      };
    } catch (e) {
      print('Error getting notification settings: $e');
      return null;
    }
  }

  // Update specific notification setting
  Future<void> updateNotificationSetting(String key, bool value) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/user/notification-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'setting': key,
          'enabled': value,
        }),
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to update notification setting');
      }
    } catch (e) {
      print('Error updating notification setting: $e');
      rethrow;
    }
  }

  // Send test notification with email and type
  Future<void> sendTestNotification(String email, String type) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/notifications/send-test'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,   // Truyền email trực tiếp
          'type': type,     // Loại thông báo
        }),
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to send test notification');
      }
    } catch (e) {
      print('Error sending test notification: $e');
      rethrow;
    }
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'type': type,
          'title': title,
          'message': message,
          'data': data,
        }),
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Send bulk notifications
  Future<void> sendBulkNotification({
    required String type,
    required String title,
    required String message,
    List<String>? userIds,
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/notifications/send-bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'type': type,
          'title': title,
          'message': message,
          'userIds': userIds,
          'data': data,
        }),
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to send bulk notification');
      }
    } catch (e) {
      print('Error sending bulk notification: $e');
      rethrow;
    }
  }

  // Get notification templates
  Future<List<Map<String, dynamic>>> getNotificationTemplates() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/notifications/templates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['templates'] ?? []);
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting notification templates: $e');
      return [];
    }
  }
}
