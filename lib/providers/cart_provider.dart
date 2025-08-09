import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;
  String? _error;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final CartService _cartService = CartService();

  Future<void> fetchCart(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cart = await _cartService.fetchCart(userId);
    } catch (e) {
      _error = e.toString();
      // ignore: avoid_print
      print('CartProvider.fetchCart error: ${_error}');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(String userId, String productId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Note: Stock validation should be handled by backend
      
      final success = await _cartService.addToCart(userId, productId, quantity);
      if (success) {
        await fetchCart(userId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Không thể thêm sản phẩm vào giỏ hàng';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _cartService.removeFromCart(userId, productId);
      await fetchCart(userId); // Đảm bảo fetch lại giỏ hàng mới nhất
    } catch (e) {
      _error = e.toString();
      // ignore: avoid_print
      print('CartProvider.removeFromCart error: ${_error}');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCart(String userId, String productId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _cartService.updateCart(userId, productId, quantity);
      await fetchCart(userId);
    } catch (e) {
      _error = e.toString();
      // ignore: avoid_print
      print('CartProvider.updateCart error: ${_error}');
    }
    _isLoading = false;
    notifyListeners();
  }
} 