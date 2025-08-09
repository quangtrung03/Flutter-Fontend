import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/review_model.dart';

class ReviewService {
  final String baseUrl = AppConfig.review;

  Future<List<Review>> fetchReviews(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/$productId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List reviewList = data['data'] ?? [];
        return reviewList.map((e) => Review.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<bool> addReview(Review review) async {
    final reviewData = {
      'productId': review.productId,
      'userId': review.userId,
      'userName': review.userName,
      'reviewMessage': review.comment,
      'reviewValue': review.rating,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reviewData),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }
} 