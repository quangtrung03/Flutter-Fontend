import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/services/chatbot_service.dart';
import 'package:do_an_mobile_nc/services/auth_service.dart';
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/models/voucher_model.dart';
import 'package:do_an_mobile_nc/models/order_model.dart';
import 'package:do_an_mobile_nc/screens/product/product_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Thêm package này
import 'package:do_an_mobile_nc/theme/colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();
  bool _isProcessing = false;

  final Map<String, String> categoryMap = {
    'tất cả': '',
    'cà phê': 'caPhe',
    'trà sữa': 'traSua',
    'bánh ngọt': 'banhNgot',
    'đá xay': 'daXay',
    'bán chạy': 'bestSeller',
  };

  void _handleUserMessage(String message) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _messages.add({'sender': 'user', 'text': message});
    });

    setState(() {
      _messages.add({'sender': 'bot', 'text': 'Đang nhập...', 'products': null});
    });

    await Future.delayed(Duration(milliseconds: 2000 + (DateTime.now().millisecond % 1000)));

    String response;
    List<Product>? products;
    
    try {
      response = await _processMessage(message.toLowerCase());
      
      // Check if response contains products
      if (response.startsWith('PRODUCTS_RESPONSE|')) {
        final parts = response.split('|');
        final productCount = int.parse(parts[1]);
        response = parts[2]; // The actual message
        
        // Get the products based on the intent
        final intent = _detectIntent(message.toLowerCase());
        final entities = _extractEntities(message.toLowerCase());
        
        if (intent == 'search_product') {
          if (entities['category'] != null) {
            products = await _dataService.searchProductsByCategory(entities['category']!);
          } else if (entities['keywords'] != null) {
            products = await _dataService.searchProducts(entities['keywords']!);
          }
          
          // Apply filters
          if (products != null) {
            if (entities['maxPrice'] != null) {
              products = products.where((p) => p.price <= entities['maxPrice']!).toList();
            }
            if (entities['inStock'] == true) {
              products = products.where((p) => p.stockStatus == 'Còn hàng').toList();
            }
          }
        } else if (intent == 'best_seller') {
          products = await _dataService.searchProductsByCategory('bestSeller');
        }
      }
    } catch (e) {
      print('❌ Handle message error: $e');
      response = 'Lỗi hệ thống: $e. Vui lòng thử lại sau!';
    }

    setState(() {
      _messages.removeLast(); // Remove "Đang nhập..." message
      _messages.add({
        'sender': 'bot', 
        'text': response, 
        'products': products
      });
      _isProcessing = false;
      print('📝 Updated bot message with ${products?.length ?? 0} products: $response');
    });

    _controller.clear();
  }

  Future<String> _processMessage(String message) async {
    try {
      final intent = _detectIntent(message);
      final entities = _extractEntities(message);
      print('🔍 Intent detected: $intent, Entities: $entities');

      switch (intent) {
        case 'list_products':
          print('ℹ️ List products intent triggered');
          return 'Xin lỗi, danh sách sản phẩm quá dài! Bạn có thể hỏi cụ thể như "cà phê nào ngon" hoặc "sản phẩm bán chạy".';
        
        case 'voucher':
          print('ℹ️ Fetching vouchers...');
          final vouchers = await _dataService.getVouchers();
          if (vouchers.isEmpty) {
            print('⚠️ No vouchers found');
            return 'Hiện tại không có voucher nào. Bạn muốn xem sản phẩm thay không?';
          }
          print('✅ Fetched ${vouchers.length} vouchers');
          return 'Danh sách voucher đang hoạt động:\n${vouchers.where((v) => v.isActive).map((v) => "${v.code} - ${v.displayValue}").join("\n")}';
        
        case 'order':
          print('ℹ️ Checking order history...');
          final isLoggedIn = await _authService.isLoggedIn();
          if (!isLoggedIn) {
            print('⚠️ User not logged in');
            return '🔐 Để xem lịch sử đơn hàng, bạn cần đăng nhập trước nhé!\n\n'
                   '📱 Cách đăng nhập:\n'
                   '• Nhấn vào tab "Cá nhân" ở cuối màn hình\n'
                   '• Chọn "Đăng nhập" và nhập thông tin\n'
                   '• Sau đó quay lại hỏi mình về đơn hàng\n\n'
                   '💡 Hoặc bạn có thể hỏi mình về sản phẩm, voucher thay thế nhé!';
          }
          final userData = await _authService.getSavedUser();
          if (userData == null || userData['_id'] == null) {
            print('⚠️ No user data or user ID');
            return '❌ Không thể lấy thông tin tài khoản.\n\n'
                   '🔄 Hãy thử:\n'
                   '• Đăng xuất và đăng nhập lại\n'
                   '• Kiểm tra kết nối mạng\n'
                   '• Liên hệ hỗ trợ nếu vấn đề vẫn tiếp tục';
          }
          final userId = userData['_id'] as String;
          print('ℹ️ Fetching orders for user: $userId');
          try {
            final orders = await _dataService.getOrderHistory(userId);
            if (orders.isEmpty) {
              print('⚠️ No orders found for user $userId');
              return '📋 Bạn chưa có đơn hàng nào.\n\n'
                     '☕ Khám phá menu Fresh Drinks ngay:\n'
                     '• Hỏi "cà phê nào ngon?" để xem cà phê\n'
                     '• Hỏi "trà sữa bán chạy" để xem trà sữa hot\n'
                     '• Hỏi "sản phẩm bán chạy" để xem top món\n\n'
                     '🎁 Hoặc hỏi "voucher" để xem ưu đãi hôm nay!';
            }
            print('✅ Fetched ${orders.length} orders');
            return _createOrderSummary(orders);
          } catch (e) {
            print('❌ Error fetching orders: $e');
            return '❌ Không thể tải lịch sử đơn hàng lúc này.\n\n'
                   '🔄 Vui lòng:\n'
                   '• Kiểm tra kết nối mạng\n'
                   '• Thử lại sau vài phút\n'
                   '• Liên hệ hỗ trợ nếu lỗi vẫn tiếp tục\n\n'
                   '💡 Trong lúc chờ, bạn có thể hỏi về sản phẩm hoặc voucher nhé!';
          }

        case 'order_detail':
          print('ℹ️ Fetching specific order status...');
          final isLoggedIn = await _authService.isLoggedIn();
          if (!isLoggedIn) {
            return '🔐 Vui lòng đăng nhập để xem chi tiết đơn hàng.\n'
                   'Nhấn vào tab "Cá nhân" để đăng nhập nhé!';
          }
          final userData = await _authService.getSavedUser();
          if (userData == null || userData['_id'] == null) {
            return '❌ Không thể lấy thông tin tài khoản. Vui lòng đăng nhập lại.';
          }
          final userId = userData['_id'] as String;
          try {
            final orders = await _dataService.getOrderHistory(userId);
            final requestedStatus = entities['orderStatus'] as String?;
            if (requestedStatus != null) {
              return _getOrdersByStatus(orders, requestedStatus);
            }
            return 'Vui lòng chỉ định loại đơn hàng bạn muốn xem.';
          } catch (e) {
            print('❌ Error fetching order details: $e');
            return '❌ Không thể tải chi tiết đơn hàng.\n'
                   'Kiểm tra kết nối mạng và thử lại sau nhé!';
          }
        
        case 'search_product':
          print('ℹ️ Searching products...');
          List<Product> products = [];
          
          if (entities['category'] != null) {
            print('🔍 Searching by category: ${entities['category']}');
            try {
              products = await _dataService.searchProductsByCategory(entities['category']!);
              print('📡 Search result: ${products.length} products found');
            } catch (e) {
              print('❌ Search error: $e');
              return 'Lỗi khi tìm kiếm danh mục ${entities['categoryKey']}: $e. Vui lòng thử lại!';
            }
          } else if (entities['keywords'] != null) {
            print('🔍 Searching by keywords: ${entities['keywords']}');
            products = await _dataService.searchProducts(entities['keywords']!);
          } else {
            print('⚠️ No category or keywords provided');
            return 'Vui lòng cung cấp danh mục hoặc từ khóa (ví dụ: "cà phê" hoặc "trà sữa").';
          }

          if (entities['maxPrice'] != null) {
            products = products.where((p) => p.price <= entities['maxPrice']!).toList();
            print('🔍 Filtered by maxPrice: ${entities['maxPrice']}');
          }
          if (entities['inStock'] == true) {
            products = products.where((p) => p.stockStatus == 'Còn hàng').toList();
            print('🔍 Filtered by inStock');
          }

          if (products.isEmpty) {
            print('⚠️ No products found');
            String suggestion = entities['category'] != null
                ? 'Không tìm thấy sản phẩm nào trong danh mục ${entities["categoryKey"]}. Bạn muốn xem danh mục khác như Trà sữa hoặc Bánh ngọt?'
                : 'Không tìm thấy sản phẩm nào với từ khóa "${message}". Thử "Cà phê sữa đá" hoặc "sản phẩm bán chạy" nhé!';
            return suggestion;
          }

          return _createProductResponse(products, 'Dưới đây là các sản phẩm phù hợp với tình trạng hoặc mong muốn: (Nhấn vào tên để xem chi tiết)');

        case 'best_seller':
          print('ℹ️ Fetching best seller products...');
          List<Product> bestSellerProducts = [];
          try {
            bestSellerProducts = await _dataService.searchProductsByCategory('bestSeller');
            print('📡 Best seller result: ${bestSellerProducts.length} products found');
          } catch (e) {
            print('❌ Best seller error: $e');
            return 'Lỗi khi tìm sản phẩm bán chạy: $e. Vui lòng thử lại!';
          }
          if (bestSellerProducts.isEmpty) {
            print('⚠️ No best seller products found');
            return 'Hiện tại không có sản phẩm nào trong danh mục bán chạy. Bạn muốn xem danh mục khác không?';
          }
          
          return _createProductResponse(bestSellerProducts, 'Dưới đây là các sản phẩm bán chạy: (Nhấn vào tên để xem chi tiết)');

        case 'greeting':
          print('ℹ️ Greeting intent triggered');
          return 'Chào bạn! Mình là chatbot của Fresh Drinks, sẵn sàng giúp bạn tìm món ngon. Hôm nay bạn muốn thử cà phê, trà sữa hay sản phẩm bán chạy?';
          
        
        case 'help':
          print('ℹ️ Help intent triggered');
          return 'Mình có thể giúp bạn:\n'
                 '- Tìm sản phẩm (ví dụ: "cà phê dưới 40k", "trà sữa còn hàng")\n'
                 '- Tìm sản phẩm bán chạy (nói "sản phẩm bán chạy")\n'
                 '- Xem voucher đang hoạt động\n'
                 '- Xem lịch sử đơn hàng (nói "đơn hàng")\n'
                 '- Xem đơn hàng theo trạng thái (ví dụ: "đơn chờ xác nhận", "đơn đã giao")\n'
                 'Hãy thử hỏi mình nhé!';
        
        default:
          print('⚠️ Unknown intent for message: $message');
          return 'Mình chưa hiểu lắm! Bạn có thể hỏi về sản phẩm, voucher, hoặc đơn hàng. Ví dụ: "Cà phê nào dưới 40k?" hoặc "sản phẩm bán chạy".';
      }
    } catch (e) {
      print('❌ Process message error: $e');
      return 'Oops, có lỗi xảy ra: ${e.toString()}. Bạn thử hỏi lại nhé!';
    }
  }

  String _createProductResponse(List<Product> products, String message) {
    return "PRODUCTS_RESPONSE|${products.length}|$message";
  }

  String _createOrderSummary(List<Order> orders) {
    // Đếm số lượng đơn hàng theo trạng thái
    final Map<String, int> statusCount = {};
    final Map<String, String> statusDisplay = {
      'pending': 'chờ xác nhận',
      'confirmed': 'đã xác nhận', 
      'shipping': 'đang vận chuyển',
      'delivered': 'đã giao',
      'cancelled': 'đã hủy'
    };

    for (final order in orders) {
      final status = order.orderStatus?.toLowerCase() ?? 'unknown';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    String summary = 'Bạn có tổng cộng ${orders.length} đơn hàng:\n';
    
    statusCount.forEach((status, count) {
      final displayStatus = statusDisplay[status] ?? status;
      summary += '• $count đơn $displayStatus\n';
    });

    summary += '\nBạn muốn xem chi tiết đơn hàng nào?\n';
    summary += 'Ví dụ: "đơn chờ xác nhận" hoặc "đơn đã giao"';

    return summary;
  }

  String _getOrdersByStatus(List<Order> orders, String requestedStatus) {
    final filteredOrders = orders.where((order) {
      final orderStatus = order.orderStatus?.toLowerCase() ?? '';
      return orderStatus == requestedStatus;
    }).toList();

    if (filteredOrders.isEmpty) {
      final statusDisplay = {
        'pending': 'chờ xác nhận',
        'confirmed': 'đã xác nhận',
        'shipping': 'đang vận chuyển', 
        'delivered': 'đã giao',
        'cancelled': 'đã hủy'
      };
      
      return 'Bạn không có đơn hàng nào ${statusDisplay[requestedStatus] ?? requestedStatus}.';
    }

    String result = 'Danh sách đơn hàng ${_getStatusDisplayName(requestedStatus)}:\n\n';
    
    for (int i = 0; i < filteredOrders.length; i++) {
      final order = filteredOrders[i];
      result += '${i + 1}. Đơn #${order.id}\n';
      result += '   💰 Tổng tiền: ${order.totalAmount} VNĐ\n';
      if (order.createdAt != null) {
        result += '   📅 Ngày đặt: ${_formatDate(order.createdAt!)}\n';
      }
      result += '   📋 Trạng thái: ${_getStatusDisplayName(order.orderStatus ?? '')}\n';
      if (i < filteredOrders.length - 1) result += '\n';
    }

    return result;
  }

  String _getStatusDisplayName(String status) {
    final statusDisplay = {
      'pending': 'chờ xác nhận',
      'confirmed': 'đã xác nhận',
      'shipping': 'đang vận chuyển',
      'delivered': 'đã giao',
      'cancelled': 'đã hủy'
    };
    return statusDisplay[status.toLowerCase()] ?? status;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _detectIntent(String message) {
    if (message.contains('product') || message.contains('sản phẩm')) {
      return 'list_products';
    } else if (message.contains('voucher')) {
      return 'voucher';
    } else if (message.contains('order') || message.contains('đơn hàng')) {
      // Kiểm tra xem có yêu cầu cụ thể về trạng thái đơn hàng không
      if (message.contains('chờ xác nhận') || message.contains('pending') ||
          message.contains('đã xác nhận') || message.contains('confirmed') ||
          message.contains('đang vận chuyển') || message.contains('shipping') ||
          message.contains('đã giao') || message.contains('delivered') ||
          message.contains('đã hủy') || message.contains('cancelled')) {
        return 'order_detail';
      }
      return 'order';
    } else if (message.contains('hello') || message.contains('xin chào') || message.contains('chào bạn')) {
      return 'greeting';
    } else if (message.contains('help') || message.contains('giúp đỡ')) {
      return 'help';
    } else if (message.contains('bán chạy') || message.contains('best seller')) {
      return 'best_seller';
    } else {
      for (var key in categoryMap.keys) {
        if (message.contains(key.toLowerCase())) {
          return 'search_product';
        }
      }
      if (message.split(' ').any((word) => word.length > 2)) {
        return 'search_product';
      }
      return 'unknown';
    }
  }

  Map<String, dynamic> _extractEntities(String message) {
    final entities = <String, dynamic>{};

    for (var key in categoryMap.keys) {
      if (message.contains(key.toLowerCase())) {
        entities['category'] = categoryMap[key];
        entities['categoryKey'] = key;
        break;
      }
    }

    final keywords = message.split(' ').where((word) => word.length > 2).toList();
    if (keywords.isNotEmpty) {
      entities['keywords'] = keywords;
    }

    final priceMatch = RegExp(r'(dưới|nhỏ hơn)\s*(\d+)\s*(k|nghìn|vnđ)?').firstMatch(message);
    if (priceMatch != null) {
      final price = int.parse(priceMatch.group(2)!);
      entities['maxPrice'] = priceMatch.group(3) == 'k' ? price * 1000 : price;
    }

    if (message.contains('còn hàng') || message.contains('có sẵn')) {
      entities['inStock'] = true;
    }

    // Extract order status
    if (message.contains('chờ xác nhận') || message.contains('pending')) {
      entities['orderStatus'] = 'pending';
    } else if (message.contains('đã xác nhận') || message.contains('confirmed')) {
      entities['orderStatus'] = 'confirmed';
    } else if (message.contains('đang vận chuyển') || message.contains('shipping')) {
      entities['orderStatus'] = 'shipping';
    } else if (message.contains('đã giao') || message.contains('delivered')) {
      entities['orderStatus'] = 'delivered';
    } else if (message.contains('đã hủy') || message.contains('cancelled')) {
      entities['orderStatus'] = 'cancelled';
    }

    return entities;
  }

  Widget _buildProductImage(Product product) {
    // Kiểm tra nếu product có field imageUrl
    if (product.image != null && product.image!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.image!,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.brown[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getProductIcon(product.category),
            color: Colors.brown[600],
            size: 30,
          ),
        ),
        imageBuilder: (context, imageProvider) => Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      // Fallback với icon nếu không có hình ảnh
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.brown[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getProductIcon(product.category),
          color: Colors.brown[600],
          size: 30,
        ),
      );
    }
  }

  IconData _getProductIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'caphe':
      case 'cà phê':
      case 'buồn ngủ quá':
        return Icons.coffee;
      case 'trasua':
      case 'trà sữa':
      case 'trà':
        return Icons.local_cafe;
      case 'banhngot':
      case 'bánh ngọt':
      case 'đói bụng quá':
        return Icons.cake;
      case 'daxay':
      case 'đá xay':
      case 'nóng quá':
        return Icons.ac_unit;
      default:
        return Icons.local_drink;
    }
  }

  Widget _buildProductItem(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image - Sử dụng method mới để hiển thị hình ảnh
              _buildProductImage(product),
              const SizedBox(width: 12),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.description != null && product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 13, 
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} VNĐ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: product.stockStatus == 'Còn hàng' 
                                ? Colors.green[100] 
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.stockStatus ?? 'N/A',
                            style: TextStyle(
                              fontSize: 11,
                              color: product.stockStatus == 'Còn hàng' 
                                  ? Colors.green[700] 
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        backgroundColor: AppColors.primary,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                
                if (isUser) {
                  return ListTile(
                    title: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          message['text']!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  );
                } else {
                  final products = message['products'] as List<Product>?;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bot message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            message['text']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Products list
                      if (products != null && products.isNotEmpty)
                        ...products.take(5).map((product) => _buildProductItem(product)),
                      if (products != null && products.length > 5)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Và ${products.length - 5} sản phẩm khác...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isProcessing,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _isProcessing ? null : _handleUserMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isProcessing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isProcessing
                      ? null
                      : (_controller.text.isNotEmpty ? () => _handleUserMessage(_controller.text) : null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}