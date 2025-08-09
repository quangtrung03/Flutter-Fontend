import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_model.dart';

class FavoritesProvider with ChangeNotifier {
  List<String> _favoriteProductIds = [];

  List<String> get favoriteProductIds => _favoriteProductIds;

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteProductIds = prefs.getStringList('favorites') ?? [];
    notifyListeners();
  }

  Future<void> addFavorite(String productId) async {
    if (!_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.add(productId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteProductIds);
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String productId) async {
    _favoriteProductIds.remove(productId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteProductIds);
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }
} 