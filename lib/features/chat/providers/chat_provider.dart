import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String user;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.user,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      user: data['user'] ?? "مجهول",
      text: data['text'] ?? "",
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getMessages(int matchId) {
    return _db
        .collection('matches')
        .doc(matchId.toString())
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromDoc(d)).toList());
  }

  Future<void> sendMessage(int matchId, String user, String text) async {
    final msg = ChatMessage(
      id: '',
      user: user,
      text: text,
      timestamp: DateTime.now(),
    );
    await _db
        .collection('matches')
        .doc(matchId.toString())
        .collection('chat')
        .add(msg.toMap());
  }
}
