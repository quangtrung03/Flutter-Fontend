class SupportMessage {
  final String sender; // 'user' hoặc 'admin'
  final String content;
  final DateTime? createdAt;

  SupportMessage({required this.sender, required this.content, this.createdAt});

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      sender: json['sender'],
      content: json['content'],
      createdAt: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : 
                 json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
    };
  }
}

class SupportThread {
  final String id;
  final String userEmail;
  final String userName;
  final List<SupportMessage> messages;
  final DateTime? updatedAt;

  SupportThread({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.messages,
    this.updatedAt,
  });

  factory SupportThread.fromJson(Map<String, dynamic> json) {
    return SupportThread(
      id: json['_id'],
      userEmail: json['userEmail'],
      userName: json['userName'],
      messages: (json['messages'] as List).map((e) => SupportMessage.fromJson(e)).toList(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
} 