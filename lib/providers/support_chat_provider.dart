import 'package:flutter/material.dart';
import '../models/support_chat_model.dart';
import '../services/support_chat_service.dart';

class SupportChatProvider with ChangeNotifier {
  SupportThread? _thread;
  bool _isLoading = false;
  String? _error;

  SupportThread? get thread => _thread;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final SupportChatService _service = SupportChatService();

  Future<void> loadThread(String userEmail) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _thread = await _service.getThread(userEmail);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
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
} 