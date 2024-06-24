import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String message;
  final String senderId;
  final Timestamp timestamp;

  ChatMessage(
      {required this.message, required this.senderId, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'],
      senderId: map['senderId'],
      timestamp: map['timestamp'],
    );
  }
}
