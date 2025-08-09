class FeatureBanner {
  final String id;
  final String image;

  FeatureBanner({required this.id, required this.image});

  factory FeatureBanner.fromJson(Map<String, dynamic> json) {
    return FeatureBanner(
      id: json['_id'] ?? '',
      image: json['image'] ?? '',
    );
  }
} 