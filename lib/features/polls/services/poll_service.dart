import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PollService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// إنشاء تصويت لمباراة (مرة وحدة لكل matchId)
  Future<void> createPoll({
    required String matchId,
    required String question,
    required List<String> options,
  }) async {
    final docRef = _db.collection('polls').doc(matchId);
    final doc = await docRef.get();
    if (doc.exists) return; // موجود من قبل

    // نحضّر خريطة أصوات {الخيار: 0}
    final Map<String, int> votes = { for (final o in options) o: 0 };

    await docRef.set({
      'question': question,
      'options': options,
      'votes': votes,
      'userVotes': <String, String>{}, // {uid: option}
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// بث مباشر للتصويت
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamPoll(String matchId) {
    return _db.collection('polls').doc(matchId).snapshots();
  }

  /// تصويت (مرة وحدة لكل مستخدم) – باستخدام Transaction عشان ما يصير تلاعب
  Future<void> vote({
    required String matchId,
    required String option,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _db.collection('polls').doc(matchId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception('Poll not found for match $matchId');
      }
      final data = snap.data() as Map<String, dynamic>;
      final Map<String, dynamic> votes =
          Map<String, dynamic>.from(data['votes'] ?? {});
      final Map<String, dynamic> userVotes =
          Map<String, dynamic>.from(data['userVotes'] ?? {});

      // إذا سبق وصوّت، نطلع وخلاص
      if (userVotes.containsKey(uid)) {
        return;
      }

      // تأكد الخيار ضمن الخيارات
      if (!votes.containsKey(option)) {
        throw Exception('Invalid option');
      }

      // نحدّث: نزيد تصويت الخيار + نثبّت صوت المستخدم
      votes[option] = (votes[option] as int) + 1;
      userVotes[uid] = option;

      tx.update(docRef, {
        'votes': votes,
        'userVotes': userVotes,
      });
    });
  }

  /// (اختياري) قراءة صوت المستخدم الحالي
  Future<String?> getMyVote(String matchId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final snap = await _db.collection('polls').doc(matchId).get();
    if (!snap.exists) return null;
    final data = snap.data() as Map<String, dynamic>;
    final Map<String, dynamic> userVotes =
        Map<String, dynamic>.from(data['userVotes'] ?? {});
    return userVotes[uid] as String?;
  }
}
