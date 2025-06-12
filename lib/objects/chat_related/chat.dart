import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isAIMode;

  Chat({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isAIMode = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    DateTime timestamp;
    if (json['timestamp'] is Timestamp) {
      timestamp = (json['timestamp'] as Timestamp).toDate();
    } else if (json['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int);
    } else {
      timestamp = DateTime.now();
    }

    return Chat(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: timestamp,
      isRead: json['isRead'] as bool? ?? false,
      isAIMode: json['isAIMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'isAIMode': isAIMode,
    };
  }

  // For backward compatibility
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat.fromJson(map);
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}
