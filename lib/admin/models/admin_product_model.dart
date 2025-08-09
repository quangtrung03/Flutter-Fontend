class Product {
  final String id;
  final String image;
  final String title;
  final String? description;
  final String category;
  final String size;
  final int price;
  final int? salePrice;
  final int totalStock;
  final double averageReview;
  final String stockStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.image,
    required this.title,
    this.description,
    required this.category,
    required this.size,
    required this.price,
    this.salePrice,
    required this.totalStock,
    required this.averageReview,
    required this.stockStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      print('🏗️ Creating Product from JSON: $json');
      
      return Product(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        category: json['category']?.toString() ?? '',
        size: json['size']?.toString() ?? '',
        price: _parseInt(json['price']) ?? 0,
        salePrice: _parseInt(json['salePrice']),
        totalStock: _parseInt(json['totalStock']) ?? 0,
        averageReview: _parseDouble(json['averageReview']) ?? 0.0,
        stockStatus: json['stockStatus']?.toString() ?? '',
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('❌ Error creating Product from JSON: $e');
      print('🔍 Problematic JSON: $json');
      rethrow;
    }
  }
  
  // Helper methods for safe parsing
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
  
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse DateTime: $value');
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'title': title,
      'description': description,
      'category': category,
      'size': size,
      'price': price,
      'salePrice': salePrice,
      'totalStock': totalStock,
      'averageReview': averageReview,
      'stockStatus': stockStatus,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}