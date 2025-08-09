import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_product_model.dart';

class AdminProductService {
  // Lấy danh sách tất cả sản phẩm
  static Future<List<Product>> getAllProducts() async {
    try {
      final url = '${AppConfig.adminProducts}/get';
      print('🔄 Fetching products from: $url');
      final res = await http.get(Uri.parse(url));
      
      print('📡 Response status: ${res.statusCode}');
      print('📄 Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('✅ Decoded data type: ${data.runtimeType}');
        print('🔍 Full response structure: $data');
        
        // Backend trả về { success: true, data: [...] }
        List products;
        if (data is Map<String, dynamic> && data['success'] == true) {
          products = data['data'] ?? [];
        } else if (data is List) {
          products = data;
        } else {
          products = data['products'] ?? data['data'] ?? [];
        }
        
        print('📦 Products count: ${products.length}');
        
        if (products.isNotEmpty) {
          print('🔍 First product structure: ${products[0]}');
        }
        
        return products.map((e) => Product.fromJson(e)).toList();
      } else {
        print('❌ API Error: ${res.statusCode} - ${res.body}');
        throw Exception('Không thể tải sản phẩm: ${res.body}');
      }
    } catch (e) {
      print('💥 Exception in getAllProducts: $e');
      rethrow;
    }
  }

  // Thêm sản phẩm mới
  static Future<bool> addProduct(Product product) async {
    try {
      final url = '${AppConfig.adminProducts}/add';
      print('➕ Adding product to: $url');
      
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      
      print('📡 Add product response: ${res.statusCode} - ${res.body}');
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('❌ Error adding product: $e');
      return false;
    }
  }

  // Cập nhật sản phẩm
  static Future<bool> updateProduct(String id, Product product) async {
    try {
      final url = '${AppConfig.adminProducts}/edit/$id';
      print('✏️ Updating product at: $url');
      
      final res = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      
      print('📡 Update product response: ${res.statusCode} - ${res.body}');
      return res.statusCode == 200;
    } catch (e) {
      print('❌ Error updating product: $e');
      return false;
    }
  }

  // Xóa sản phẩm
  static Future<bool> deleteProduct(String id) async {
    try {
      final url = '${AppConfig.adminProducts}/delete/$id';
      print('🗑️ Deleting product at: $url');
      
      final res = await http.delete(Uri.parse(url));
      
      print('📡 Delete product response: ${res.statusCode} - ${res.body}');
      return res.statusCode == 200;
    } catch (e) {
      print('❌ Error deleting product: $e');
      return false;
    }
  }

  // Upload hình ảnh sản phẩm
  static Future<String> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.adminProducts}/upload-image'),
    );
    request.files.add(await http.MultipartFile.fromPath('my_file', imageFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);
      return decoded['url'] ?? decoded['secure_url'];
    } else {
      throw Exception('Lỗi upload hình: ${response.statusCode}');
    }
  }
}
