class User {
  final String id;
  final String userName;
  final String email;
  final String role;
  final String? avatar;
  final List<String>? addresses;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    this.avatar,
    this.addresses,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      addresses: (json['addresses'] is List)
          ? (json['addresses'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'role': role,
      'avatar': avatar,
      'addresses': addresses,
    };
  }
}
