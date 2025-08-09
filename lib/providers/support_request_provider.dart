import 'package:flutter/material.dart';
import '../models/support_request_model.dart';
import '../services/support_request_service.dart';

class SupportRequestProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  final SupportRequestService _service = SupportRequestService();

  Future<bool> sendRequest(SupportRequest request) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      final result = await _service.sendRequest(request);
      if (result) {
        _successMessage = 'Gửi yêu cầu thành công!';
      } else {
        _error = 'Gửi yêu cầu thất bại!';
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
} 