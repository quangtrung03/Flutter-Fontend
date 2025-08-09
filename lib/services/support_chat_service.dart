import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/support_chat_model.dart';

class SupportChatService {
  final String baseUrl = AppConfig.supportChat;

  Future<SupportThread?> getThread(String userEmail) async {
    try {
      // Thử lấy thread hiện có trước
      final encodedEmail = Uri.encodeComponent(userEmail);
      final response = await http.get(
        Uri.parse('$baseUrl/user/$encodedEmail'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return SupportThread.fromJson(data['data']);
        }
        return null;
      } else if (response.statusCode == 404) {
        // Thread chưa tồn tại, tạo mới bằng cách gửi tin nhắn đầu tiên
        return null;
      } else {
        throw Exception('Failed to load thread: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading thread: $e');
    }
  }

  Future<SupportThread?> sendUserMessage(String userEmail, String userName, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userEmail': userEmail,
          'userName': userName,
          'message': message,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return SupportThread.fromJson(data['data']);
        }
        return null;
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
} 