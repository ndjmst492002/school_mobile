class Contact {
  final int id;
  final int userId;
  final String fullName;
  final String role;
  final int? unreadCount;

  Contact({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.role,
    this.unreadCount,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return Contact(
      id: json['id'] ?? 0,
      userId: user?['id'] ?? json['id'] ?? 0,
      fullName: json['full_name'] ?? user?['full_name'] ?? '',
      role: json['role'] ?? user?['role'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class ChatMessage {
  final int id;
  final int sender;
  final String senderName;
  final int receiver;
  final String receiverName;
  final String content;
  final String createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.receiver,
    required this.receiverName,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      sender: json['sender'] ?? 0,
      senderName: json['sender_name'] ?? '',
      receiver: json['receiver'] ?? 0,
      receiverName: json['receiver_name'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }
}
