import 'package:flutter/material.dart';
import 'dart:async';
import '../models/support_chat_model.dart';
import '../services/admin_support_chat_service.dart';

class AdminSupportChatProvider with ChangeNotifier {
  List<SupportThread> _threads = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  Timer? _refreshTimer;

  List<SupportThread> get threads => _threads;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  final AdminSupportChatService _service = AdminSupportChatService();

  // Khởi động auto refresh
  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      autoRefresh();
    });
  }

  // Dừng auto refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  // Load tất cả threads cho admin
  Future<void> loadAllThreads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _threads = await _service.getAllThreads();
      // Sắp xếp theo thời gian cập nhật mới nhất
      _threads.sort((a, b) => (b.updatedAt ?? DateTime.now()).compareTo(a.updatedAt ?? DateTime.now()));
    } catch (e) {
      _error = e.toString();
      _threads = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Admin gửi tin nhắn
  Future<bool> sendAdminMessage(String threadId, String message) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final updatedThread = await _service.sendAdminMessage(threadId, message);
      
      if (updatedThread != null) {
        // Cập nhật thread trong danh sách
        final index = _threads.indexWhere((t) => t.id == threadId);
        if (index != -1) {
          _threads[index] = updatedThread;
          // Move to top (most recent)
          final thread = _threads.removeAt(index);
          _threads.insert(0, thread);
        }
        _isSending = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isSending = false;
    notifyListeners();
    return false;
  }

  // Lấy thread cụ thể theo ID
  Future<SupportThread?> getThreadById(String threadId) async {
    try {
      return await _service.getThreadById(threadId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Đánh dấu thread đã đọc (có thể thêm vào model sau)
  void markThreadAsRead(String threadId) {
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      // Logic đánh dấu đã đọc có thể thêm vào đây
      notifyListeners();
    }
  }

  // Get unread count
  int get unreadCount {
    return _threads.where((thread) {
      if (thread.messages.isEmpty) return false;
      return thread.messages.last.sender == 'user';
    }).length;
  }

  // Refresh single thread
  Future<void> refreshThread(String threadId) async {
    try {
      final updatedThread = await _service.getThreadById(threadId);
      if (updatedThread != null) {
        final index = _threads.indexWhere((t) => t.id == threadId);
        if (index != -1) {
          _threads[index] = updatedThread;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Auto refresh threads (có thể gọi định kỳ)
  Future<void> autoRefresh() async {
    if (!_isLoading && !_isSending) {
      await loadAllThreads();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
