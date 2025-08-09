  import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  final AuthService _authService = AuthService();

  // Khởi tạo user data từ SharedPreferences
  Future<void> initializeUser() async {
    final savedUser = await _authService.getSavedUser();
    if (savedUser != null) {
      _user = User.fromJson(savedUser);
      notifyListeners();
    }
  }

  void resetMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    final res = await _authService.login(email, password, rememberMe: rememberMe);
    if (res['success'] == true && res['user'] != null) {
      _user = User.fromJson(res['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      // Xử lý các trường hợp lỗi trả về từ backend
      if (res['message'] != null) {
        _error = res['message'];
      } else if (res['error'] != null) {
        _error = res['error'];
      } else {
        _error = 'Đăng nhập thất bại';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    final res = await _authService.register(name, email, password);
    if (res['message']?.contains('thành công') == true) {
      _successMessage = res['message'];
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      // Xử lý lỗi trả về từ backend (email hoặc userName đã tồn tại)
      if (res['message'] != null) {
        _error = res['message'];
      } else if (res['error'] != null) {
        _error = res['error'];
      } else {
        _error = 'Đăng ký thất bại';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    final res = await _authService.logout();
    _user = null;
    if (res['success'] == true) {
      _successMessage = res['message'] ?? 'Đăng xuất thành công!';
    } else {
      _error = res['message'] ?? 'Đăng xuất thất bại';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser(String id, String name, String email, String? avatar) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    final result = await _authService.updateUser(id, name, email, avatar);
    if (result) {
      _successMessage = 'Cập nhật thông tin thành công!';
      // Cập nhật lại user local
      if (_user != null) {
        _user = _user!.copyWith(userName: name, email: email, avatar: avatar);
      }
    } else {
      _error = 'Cập nhật thông tin thất bại!';
    }
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> changePassword(String id, String newPassword) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    final result = await _authService.changePassword(id, newPassword);
    if (result) {
      _successMessage = 'Đổi mật khẩu thành công!';
    } else {
      _error = 'Đổi mật khẩu thất bại!';
    }
    _isLoading = false;
    notifyListeners();
    return result;
  }
} 