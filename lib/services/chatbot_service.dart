import 'dart:convert';
   import 'package:http/http.dart' as http;
   import 'package:shared_preferences/shared_preferences.dart';
   import 'package:do_an_mobile_nc/models/product_model.dart';
   import 'package:do_an_mobile_nc/models/order_model.dart';
   import 'package:do_an_mobile_nc/models/voucher_model.dart';
   import 'package:do_an_mobile_nc/config/app_config.dart';

   class DataService {
     Future<List<Product>> searchProductsByCategory(String category) async {
       try {
         final url = '${AppConfig.products}/get?category=$category'; // Sử dụng endpoint mới
         print('🌐 Calling: $url');
         final response = await http.get(Uri.parse(url));
         print('📡 Status: ${response.statusCode}, Body: ${response.body}');
         if (response.statusCode == 200) {
           final data = json.decode(response.body);
           return (data['data'] as List).map((json) => Product.fromJson(json)).toList();
         }
         throw Exception('API error: ${response.statusCode}, ${response.body}');
       } catch (e) {
         print('❌ Error searching products by category: $e');
         throw Exception('Lỗi khi lấy sản phẩm: $e');
       }
     }

     Future<List<Voucher>> getVouchers() async {
       try {
         final prefs = await SharedPreferences.getInstance();
         final token = prefs.getString('token');
         final url = AppConfig.adminVoucher;
         print('🌐 Fetching vouchers from: $url');
         final response = await http.get(
           Uri.parse(url),
           headers: {
             'Content-Type': 'application/json',
             if (token != null) 'Authorization': 'Bearer $token',
           },
         );
         print('📡 Response status: ${response.statusCode}, body: ${response.body}');
         if (response.statusCode == 200) {
           final List<dynamic> data = jsonDecode(response.body);
           final vouchers = data.map((json) => Voucher.fromJson(json)).toList();
           print('✅ Fetched ${vouchers.length} vouchers');
           return vouchers;
         } else {
           print('❌ Failed to fetch vouchers, status: ${response.statusCode}, body: ${response.body}');
           throw Exception('Không thể tải voucher: ${response.statusCode}');
         }
       } catch (e) {
         print('❌ Error fetching vouchers: $e');
         throw Exception('Lỗi khi lấy voucher: $e');
       }
     }

     Future<List<Order>> getOrderHistory(String userId) async {
       try {
         final prefs = await SharedPreferences.getInstance();
         final token = prefs.getString('token');
         if (token == null) {
           print('⚠️ No token found, user not logged in');
           throw Exception('Chưa đăng nhập');
         }
         final url = '${AppConfig.order}?userId=$userId';
         print('🌐 Fetching order history from: $url');
         final response = await http.get(
           Uri.parse(url),
           headers: {
             'Content-Type': 'application/json',
             'Authorization': 'Bearer $token',
           },
         );
         print('📡 Response status: ${response.statusCode}, body: ${response.body}');
         if (response.statusCode == 200) {
           final List<dynamic> data = jsonDecode(response.body);
           final orders = data.map((json) => Order.fromJson(json)).toList();
           print('✅ Fetched ${orders.length} orders');
           return orders;
         } else {
           print('❌ Failed to fetch order history, status: ${response.statusCode}, body: ${response.body}');
           throw Exception('Không thể tải lịch sử đơn hàng: ${response.statusCode}');
         }
       } catch (e) {
         print('❌ Error fetching order history: $e');
         throw Exception('Lỗi khi lấy lịch sử đơn hàng: $e');
       }
     }

     Future<List<Product>> searchProducts(List<String> keywords) async {
       try {
         final products = await getProducts();
         final filtered = products.where((product) {
           final searchText = '${product.title} ${product.description ?? ''} ${product.category}'.toLowerCase();
           return keywords.any((keyword) => searchText.contains(keyword.toLowerCase()));
         }).toList();
         print('🔍 Searched ${filtered.length} products with keywords: $keywords');
         return filtered;
       } catch (e) {
         print('❌ Error searching products: $e');
         return [];
       }
     }

     // Giả định getProducts() để lấy danh sách sản phẩm từ API
     Future<List<Product>> getProducts() async {
       try {
         final url = '${AppConfig.products}/get'; // Sử dụng endpoint /get
         print('🌐 Fetching all products from: $url');
         final response = await http.get(Uri.parse(url));
         print('📡 Status: ${response.statusCode}, Body: ${response.body}');
         if (response.statusCode == 200) {
           final data = json.decode(response.body);
           return (data['data'] as List).map((json) => Product.fromJson(json)).toList();
         }
         throw Exception('API error: ${response.statusCode}, ${response.body}');
       } catch (e) {
         print('❌ Error fetching products: $e');
         throw Exception('Không thể tải sản phẩm: $e');
       }
     }
   }