import '../models/admin_address_model.dart';
import '../../config/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminAddressService {
  // Lấy thông tin địa chỉ theo ID
  static Future<Address?> getAddressById(String id) async {
    final res = await http.get(Uri.parse('${AppConfig.address}/$id'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print('DEBUG: API address raw response: $data');

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data')) return Address.fromJson(data['data']);
        if (data.containsKey('address')) return Address.fromJson(data['address']);
        return Address.fromJson(data); // fallback
      }
    }
    return null;
  }

  // Lấy tất cả địa chỉ (cho admin view)
  static Future<List<Address>> getAllAddresses() async {
    final res = await http.get(Uri.parse(AppConfig.address));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => Address.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['addresses'] ?? [];
        if (list is List) {
          return list.map((e) => Address.fromJson(e)).toList();
        }
      }
    }
    return [];
  }

  // Lấy địa chỉ theo user ID
  static Future<List<Address>> getAddressesByUserId(String userId) async {
    final res = await http.get(Uri.parse('${AppConfig.address}/user/$userId'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => Address.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['addresses'] ?? [];
        if (list is List) {
          return list.map((e) => Address.fromJson(e)).toList();
        }
      }
    }
    return [];
  }

  // Xóa địa chỉ (admin only)
  static Future<bool> deleteAddress(String id) async {
    final res = await http.delete(Uri.parse('${AppConfig.address}/$id'));
    return res.statusCode == 200;
  }

  // Verify địa chỉ (admin action)
  static Future<bool> verifyAddress(String id, bool isVerified) async {
    final res = await http.patch(
      Uri.parse('${AppConfig.address}/$id/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isVerified': isVerified}),
    );
    return res.statusCode == 200;
  }
} 