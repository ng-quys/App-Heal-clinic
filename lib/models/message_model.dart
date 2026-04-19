import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image }

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] == 'image' ? MessageType.image : MessageType.text,
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type == MessageType.image ? 'image' : 'text',
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ConversationModel {
  final String conversationId;
  final String patientId;
  final String patientName;
  final String patientInitials;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.conversationId,
    required this.patientId,
    required this.patientName,
    required this.patientInitials,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });
}
