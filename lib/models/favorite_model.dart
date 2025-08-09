class FavoriteProduct {
  final String productId;
  final String userId;

  FavoriteProduct({required this.productId, required this.userId});

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      productId: json['productId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'userId': userId,
    };
  }
} 