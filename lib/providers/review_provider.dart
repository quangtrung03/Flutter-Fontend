import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ReviewService _reviewService = ReviewService();

  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _reviews = await _reviewService.fetchReviews(productId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReview(Review review) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _reviewService.addReview(review);
      await fetchReviews(review.productId);
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
} 