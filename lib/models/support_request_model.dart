class SupportRequest {
  final String? id;
  final String userEmail;
  final String userName;
  final String message;
  final String? response;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  SupportRequest({
    this.id,
    required this.userEmail,
    required this.userName,
    required this.message,
    this.response,
    this.createdAt,
    this.respondedAt,
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      id: json['_id'],
      userEmail: json['userEmail'],
      userName: json['userName'],
      message: json['message'],
      response: json['response'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'userName': userName,
      'message': message,
    };
  }
} 