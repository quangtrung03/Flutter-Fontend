class FeatureBanner {
  final String id;
  final String image;
  final String? title;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FeatureBanner({
    required this.id,
    required this.image,
    this.title,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory FeatureBanner.fromJson(Map<String, dynamic> json) {
    return FeatureBanner(
      id: json['_id'] ?? json['id'] ?? '',
      image: json['image'] ?? '',
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  FeatureBanner copyWith({
    String? id,
    String? image,
    String? title,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeatureBanner(
      id: id ?? this.id,
      image: image ?? this.image,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
