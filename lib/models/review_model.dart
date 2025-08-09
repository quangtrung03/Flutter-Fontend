class Review {
  final String id;
  final String userId;
  final String productId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      rating: json['reviewValue'] ?? json['rating'] ?? 0,
      comment: json['reviewMessage'] ?? json['comment'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'productId': productId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
} 