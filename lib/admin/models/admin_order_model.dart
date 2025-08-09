import 'admin_address_model.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> cartItems;
  final String addressId; // sửa thành String
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final int totalAmount;
  final String? voucherCode;
  final DateTime orderDate;
  final Address? address; // luôn null, chỉ lấy qua API riêng

  Order({
    required this.id,
    required this.userId,
    required this.cartItems,
    required this.addressId,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    this.voucherCode,
    required this.orderDate,
    this.address,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      userId: _parseIdField(json['userId']),
      addressId: _parseIdField(json['addressId']),
      orderStatus: json['orderStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      totalAmount: (json['totalAmount'] is int) ? json['totalAmount'] : 
                   (json['totalAmount'] is double) ? json['totalAmount'].toInt() : 0,
      voucherCode: json['voucherCode'],
      // 🔧 FIX: Safe date parsing với fallback
      orderDate: _parseDate(json['orderDate']) ?? 
                 _parseDate(json['createdAt']) ?? 
                 DateTime.now(),
      cartItems: (json['cartItems'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      address: null, // luôn null, chỉ lấy qua API riêng
    );
  }

  /// Luôn trả về String id, bất kể backend trả về String hay Map
  static String _parseIdField(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString() ?? value['id']?.toString() ?? '';
    }
    return value.toString();
  }

  // Helper method để extract string value safely
  static String _extractStringValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      // Nếu là object, lấy _id hoặc id
      return value['_id'] ?? value['id'] ?? '';
    }
    return value.toString();
  }

  // 🔧 Helper method để parse date an toàn
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is String) {
      return DateTime.tryParse(dateValue);
    }
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'addressId': addressId,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'voucherCode': voucherCode,
      'orderDate': orderDate.toIso8601String(),
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
    };
  }
}

class CartItem {
  final String productId;
  final String title;
  final String image;
  final int price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: Order._extractStringValue(json['productId']),
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }
}
