import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/feature_banner_model.dart';

class FeatureService {
  final String baseUrl = AppConfig.feature;

  Future<List<FeatureBanner>> fetchBanners() async {
    print('DEBUG: Fetching banners from: $baseUrl/get');
    final response = await http.get(Uri.parse('$baseUrl/get'));
    
    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Handle different response formats
      if (data is Map<String, dynamic>) {
        if (data['success'] == true && data['data'] is List) {
          final banners = (data['data'] as List).map((e) => FeatureBanner.fromJson(e)).toList();
          print('DEBUG: Successfully parsed ${banners.length} banners');
          return banners;
        } else if (data['data'] is List) {
          // Handle case where success field might not exist
          final banners = (data['data'] as List).map((e) => FeatureBanner.fromJson(e)).toList();
          print('DEBUG: Successfully parsed ${banners.length} banners (no success field)');
          return banners;
        }
      } else if (data is List) {
        // Handle direct array response
        final banners = (data as List).map((e) => FeatureBanner.fromJson(e)).toList();
        print('DEBUG: Successfully parsed ${banners.length} banners (direct array)');
        return banners;
      }
      
      print('DEBUG: Invalid response format: $data');
      throw Exception('Invalid response format');
    } else {
      print('DEBUG: Failed to load banners, status: ${response.statusCode}');
      throw Exception('Failed to load banners: ${response.statusCode}');
    }
  }
} 