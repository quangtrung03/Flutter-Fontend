class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  // Helper getters
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // Get icon based on notification type
  String get iconPath {
    switch (type) {
      case 'newOrder':
        return 'assets/icons/order.png';
      case 'orderStatusUpdate':
        return 'assets/icons/update.png';
      case 'orderDelivered':
        return 'assets/icons/delivered.png';
      case 'orderCancelled':
        return 'assets/icons/cancelled.png';
      case 'promotion':
        return 'assets/icons/promotion.png';
      case 'newProduct':
        return 'assets/icons/product.png';
      default:
        return 'assets/icons/notification.png';
    }
  }

  // Get color based on notification type
  String get colorHex {
    switch (type) {
      case 'newOrder':
        return '#4CAF50'; // Green
      case 'orderStatusUpdate':
        return '#FF9800'; // Orange
      case 'orderDelivered':
        return '#2196F3'; // Blue
      case 'orderCancelled':
        return '#F44336'; // Red
      case 'promotion':
        return '#9C27B0'; // Purple
      case 'newProduct':
        return '#795548'; // Brown
      default:
        return '#607D8B'; // Blue Grey
    }
  }
}

class NotificationSettings {
  final String userId;
  final Map<String, bool> settings;
  final DateTime updatedAt;

  NotificationSettings({
    required this.userId,
    required this.settings,
    required this.updatedAt,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      userId: json['userId'] ?? '',
      settings: Map<String, bool>.from(json['settings'] ?? {}),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'settings': settings,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool isEnabled(String notificationType) {
    return settings[notificationType] ?? false;
  }
}
