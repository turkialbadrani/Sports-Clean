import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 إرسال رسالة جديدة
  Future<void> sendMessage({
    required String matchId,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection("matches_chat")
        .doc(matchId)
        .collection("messages")
        .add({
      "uid": user.uid,
      "userName": user.displayName ?? "مجهول",
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 جلب الرسائل (كـ Stream حيّ)
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String matchId) {
    return _db
        .collection("matches_chat")
        .doc(matchId)
        .collection("messages")
        .orderBy("createdAt", descending: true) // آخر رسالة أول
        .snapshots();
  }
}
