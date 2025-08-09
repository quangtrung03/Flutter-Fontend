import 'dart:async';
import 'package:flutter/material.dart';
import '../models/support_chat_model.dart';
import '../services/support_chat_service.dart';

class EnhancedSupportChatProvider with ChangeNotifier {
  SupportThread? _thread;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 5);

  SupportThread? get thread => _thread;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final SupportChatService _service = SupportChatService();

  // Auto-refresh timer
  void startAutoRefresh(String userEmail) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_isLoading) {
        _refreshThread(userEmail);
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> loadThread(String userEmail) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _thread = await _service.getThread(userEmail);
      startAutoRefresh(userEmail); // Bắt đầu auto-refresh
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _refreshThread(String userEmail) async {
    try {
      final newThread = await _service.getThread(userEmail);
      if (newThread != null && newThread.messages.length != _thread?.messages.length) {
        _thread = newThread;
        notifyListeners();
      }
    } catch (e) {
      // Silent fail cho auto-refresh
      debugPrint('Auto-refresh failed: $e');
    }
  }

  Future<void> sendUserMessage(String userEmail, String userName, String message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _thread = await _service.sendUserMessage(userEmail, userName, message);
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  // Reset state
  void reset() {
    stopAutoRefresh();
    _thread = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Kiểm tra tin nhắn mới
  bool get hasNewMessages {
    if (_thread?.messages.isEmpty ?? true) return false;
    final lastMessage = _thread!.messages.last;
    return lastMessage.sender == 'admin';
  }

  // Đếm tin nhắn chưa đọc từ admin
  int get unreadAdminMessages {
    if (_thread?.messages.isEmpty ?? true) return 0;
    int count = 0;
    for (int i = _thread!.messages.length - 1; i >= 0; i--) {
      final message = _thread!.messages[i];
      if (message.sender == 'admin') {
        count++;
      } else {
        break; // Dừng khi gặp tin nhắn của user
      }
    }
    return count;
  }
}
