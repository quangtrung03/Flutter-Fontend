import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class AdminDashboardService {
  static Future<int> getOrderCount() async {
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}/total-orders'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['totalOrders'] ?? 0;
    }
    return 0;
  }

  static Future<int> getUserCount() async {
    final res = await http.get(Uri.parse('${AppConfig.adminUsers}/count?role=user'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  static Future<int> getAdminCount() async {
    final res = await http.get(Uri.parse('${AppConfig.adminUsers}/count?role=admin'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  static Future<double> getTotalRevenue() async {
    final res = await http.get(Uri.parse('${AppConfig.adminOrders}/total-revenue'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['totalRevenue'] ?? 0).toDouble();
    }
    return 0.0;
  }

  // ✅ Lấy thống kê dashboard tổng quan với API mới
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final res = await http.get(Uri.parse('${AppConfig.adminOrders}/dashboard-stats'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? _getMockDashboardStats();
      }
    } catch (e) {
      print('Dashboard stats error: $e');
    }
    return _getMockDashboardStats();
  }

  // ✅ Lấy dữ liệu sales theo tháng với dữ liệu thật
  static Future<List<Map<String, dynamic>>> getSalesPerMonth([int? year]) async {
    try {
      String url = '${AppConfig.adminOrders}/sales-per-month';
      if (year != null) {
        url += '?year=$year';
      }

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
    } catch (e) {
      print('Sales per month error: $e');
    }
    return _getMockSalesData();
  }

  // Mock data khi API không khả dụng
  static Map<String, dynamic> _getMockDashboardStats() {
    return {
      'revenue': {
        'total': 5420000,
        'today': 320000,
        'week': 1200000,
        'month': 3500000,
      },
      'orders': {
        'total': 156,
        'today': 8,
        'week': 32,
        'month': 98,
      },
      'customers': 89,
      'topProducts': [
        {'name': 'Cà phê đen', 'totalSold': 45, 'revenue': 675000},
        {'name': 'Trà sữa', 'totalSold': 38, 'revenue': 950000},
        {'name': 'Bánh croissant', 'totalSold': 25, 'revenue': 750000},
      ],
      'last7Days': [
        {'_id': {'day': 1}, 'revenue': 180000, 'orders': 4},
        {'_id': {'day': 2}, 'revenue': 220000, 'orders': 6},
        {'_id': {'day': 3}, 'revenue': 150000, 'orders': 3},
        {'_id': {'day': 4}, 'revenue': 280000, 'orders': 8},
        {'_id': {'day': 5}, 'revenue': 190000, 'orders': 5},
        {'_id': {'day': 6}, 'revenue': 240000, 'orders': 7},
        {'_id': {'day': 7}, 'revenue': 320000, 'orders': 8},
      ]
    };
  }

  static List<Map<String, dynamic>> _getMockSalesData() {
    return [
      {'name': 'Jan', 'sales': 1200000, 'orders': 25, 'salesInK': 1200},
      {'name': 'Feb', 'sales': 1500000, 'orders': 32, 'salesInK': 1500},  
      {'name': 'Mar', 'sales': 1800000, 'orders': 28, 'salesInK': 1800},
      {'name': 'Apr', 'sales': 2100000, 'orders': 35, 'salesInK': 2100},
      {'name': 'May', 'sales': 1900000, 'orders': 30, 'salesInK': 1900},
      {'name': 'Jun', 'sales': 2300000, 'orders': 38, 'salesInK': 2300},
      {'name': 'Jul', 'sales': 2500000, 'orders': 42, 'salesInK': 2500},
      {'name': 'Aug', 'sales': 2200000, 'orders': 36, 'salesInK': 2200},
      {'name': 'Sep', 'sales': 2000000, 'orders': 33, 'salesInK': 2000},
      {'name': 'Oct', 'sales': 2400000, 'orders': 40, 'salesInK': 2400},
      {'name': 'Nov', 'sales': 2600000, 'orders': 44, 'salesInK': 2600},
      {'name': 'Dec', 'sales': 2800000, 'orders': 48, 'salesInK': 2800},
    ];
  }
}
