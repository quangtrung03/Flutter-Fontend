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
      productId: json['productId']?.toString() ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }
}
