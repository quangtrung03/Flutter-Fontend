class Blog {
  final String id;
  final String title;
  final String content;
  final String image;
  final String slug;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.image,
    required this.slug,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
      slug: json['slug'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "image": image,
      "slug": slug,
      "date": date.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
