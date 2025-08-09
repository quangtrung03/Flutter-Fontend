import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../models/admin_voucher_model.dart';

class AdminVoucherService {
  // Lấy danh sách tất cả voucher
  static Future<List<Voucher>> getAllVouchers() async {
    final res = await http.get(Uri.parse(AppConfig.adminVoucher));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => Voucher.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['vouchers'] ?? [];
        if (list is List) {
          return list.map((e) => Voucher.fromJson(e)).toList();
        }
      }
    } else {
      throw Exception('Lỗi tải danh sách voucher: ${res.body}');
    }
    return [];
  }

  // Lấy thông tin voucher theo ID
  static Future<Voucher?> getVoucherById(String id) async {
    final res = await http.get(Uri.parse('${AppConfig.adminVoucher}/$id'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data')) return Voucher.fromJson(data['data']);
        if (data.containsKey('voucher')) return Voucher.fromJson(data['voucher']);
        return Voucher.fromJson(data);
      }
    }
    return null;
  }

  // Tạo voucher mới
  static Future<bool> createVoucher(Voucher voucher) async {
    final res = await http.post(
      Uri.parse(AppConfig.adminVoucher),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(voucher.toJson()),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Cập nhật voucher
  static Future<bool> updateVoucher(String id, Voucher voucher) async {
    final res = await http.put(
      Uri.parse('${AppConfig.adminVoucher}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(voucher.toJson()),
    );
    return res.statusCode == 200;
  }

  // Xóa voucher
  static Future<bool> deleteVoucher(String id) async {
    final res = await http.delete(Uri.parse('${AppConfig.adminVoucher}/$id'));
    return res.statusCode == 200;
  }

  // Active/Deactive voucher
  static Future<bool> toggleVoucherStatus(String id, bool isActive) async {
    final res = await http.patch(
      Uri.parse('${AppConfig.adminVoucher}/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isActive': isActive}),
    );
    return res.statusCode == 200;
  }

  // Tìm kiếm voucher
  static Future<List<Voucher>> searchVouchers(String query) async {
    final res = await http.get(
      Uri.parse('${AppConfig.adminVoucher}/search?q=${Uri.encodeComponent(query)}')
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => Voucher.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['vouchers'] ?? [];
        if (list is List) {
          return list.map((e) => Voucher.fromJson(e)).toList();
        }
      }
    }
    return [];
  }

  // Lấy voucher theo loại
  static Future<List<Voucher>> getVouchersByType(String type) async {
    final res = await http.get(Uri.parse('${AppConfig.adminVoucher}/type/$type'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => Voucher.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['vouchers'] ?? [];
        if (list is List) {
          return list.map((e) => Voucher.fromJson(e)).toList();
        }
      }
    }
    return [];
  }

  // Lấy thống kê voucher
  static Future<Map<String, dynamic>> getVoucherStats() async {
    final res = await http.get(Uri.parse('${AppConfig.adminVoucher}/stats'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : {};
    }
    return {};
  }

  // Bulk operation - tạo nhiều voucher cùng lúc
  static Future<bool> createBulkVouchers(List<Voucher> vouchers) async {
    final res = await http.post(
      Uri.parse('${AppConfig.adminVoucher}/bulk'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vouchers.map((v) => v.toJson()).toList()),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // Kiểm tra voucher có hợp lệ không
  static Future<Map<String, dynamic>> validateVoucher(String code) async {
    final res = await http.post(
      Uri.parse('${AppConfig.adminVoucher}/validate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return {'valid': false, 'message': 'Voucher không hợp lệ'};
  }

  // Lấy lịch sử sử dụng voucher
  static Future<List<dynamic>> getVoucherUsageHistory(String voucherId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.adminVoucher}/$voucherId/usage')
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        return data['data'] ?? data['usage'] ?? [];
      }
    }
    return [];
  }
}
