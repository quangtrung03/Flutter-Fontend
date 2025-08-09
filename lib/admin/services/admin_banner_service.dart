import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_banner_model.dart';

class AdminBannerService {
  // Lấy danh sách tất cả banner
  static Future<List<FeatureBanner>> getAllBanners() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/common/feature/get'));
    if (res.statusCode == 200)   {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded.map((e) => FeatureBanner.fromJson(e)).toList();
      } else if (decoded is Map<String, dynamic>) {
        final list = decoded['data'] ?? decoded['features'] ?? decoded['banners'] ?? [];
        if (list is List) {
          return list.map((e) => FeatureBanner.fromJson(e)).toList();
        }
      }
    } else {
      throw Exception('Lỗi tải banner: ${res.body}');
    }
    return [];
  }

  // Thêm banner mới
  static Future<bool> addBanner(FeatureBanner banner) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/common/feature/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(banner.toJson()),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Thêm banner chỉ với URL ảnh (cho tương thích với code cũ)
  static Future<bool> addBannerWithImage(String imageUrl, {String? title, String? description}) async {
    final bannerData = {
      'image': imageUrl,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'isActive': true,
    };
    
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/common/feature/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bannerData),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Cập nhật banner
  static Future<bool> updateBanner(String id, FeatureBanner banner) async {
    final res = await http.put(
      Uri.parse('${AppConfig.baseUrl}/common/feature/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(banner.toJson()),
    );
    return res.statusCode == 200;
  }

  // Xóa banner
  static Future<bool> deleteBanner(String id) async {
    final res = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/common/feature/delete/$id')
    );
    return res.statusCode == 200;
  }

  // Upload ảnh banner
  static Future<String> uploadBannerImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.baseUrl}/common/feature/upload-image'),
    );
    request.files.add(await http.MultipartFile.fromPath('my_file', imageFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final decoded = jsonDecode(resData);
      return decoded['url'] ?? decoded['secure_url'] ?? decoded['imageUrl'] ?? '';
    } else {
      throw Exception('Lỗi upload ảnh banner: ${response.statusCode}');
    }
  }

  // Thay đổi trạng thái banner (active/inactive)
  static Future<bool> toggleBannerStatus(String id, bool isActive) async {
    final res = await http.patch(
      Uri.parse('${AppConfig.baseUrl}/common/feature/toggle/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isActive': isActive}),
    );
    return res.statusCode == 200;
  }
}
