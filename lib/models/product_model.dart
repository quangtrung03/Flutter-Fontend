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
    return Product(
      id: json['_id'],
      image: json['image'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      size: json['size'],
      price: json['price'],
      salePrice: json['salePrice'],
      totalStock: json['totalStock'],
      averageReview: (json['averageReview'] ?? 0).toDouble(),
      stockStatus: json['stockStatus'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
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
