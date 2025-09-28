import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileService {
  static final _users = FirebaseFirestore.instance.collection('users');

  /// ستريم اسم العرض من Firestore، مع fallback لِـ FirebaseAuth.displayName
  static Stream<String?> displayNameStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data != null && data['displayName'] is String && (data['displayName'] as String).trim().isNotEmpty) {
        return data['displayName'] as String;
      }
      return FirebaseAuth.instance.currentUser?.displayName;
    });
  }

  /// يطلب اسم *فقط إذا ما كان موجود*
  static Future<void> promptForDisplayNameIfNeeded(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await _users.doc(user.uid).get();
    final hasFirestoreName = doc.exists && (doc.data()?['displayName'] ?? '').toString().trim().isNotEmpty;
    final hasAuthName = (user.displayName ?? '').trim().isNotEmpty;

    if (hasFirestoreName || hasAuthName) return;

    final chosen = await _askForNameDialog(context, initial: '');
    if (chosen == null) return;

    await setDisplayName(user.uid, chosen);
  }

  /// تعديل الاسم دائمًا (يفتح الدايالوج حتى لو فيه اسم سابق)
  static Future<bool> changeDisplayName(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // اسم مبدئي من Firestore أو Auth
    String initial = (await _users.doc(user.uid).get()).data()?['displayName'] ?? '';
    if (initial.trim().isEmpty) {
      initial = (user.displayName ?? '').trim();
    }

    final chosen = await _askForNameDialog(context, initial: initial);
    if (chosen == null) return false; // المستخدم لغى
    await setDisplayName(user.uid, chosen);
    return true;
  }

  /// تحديث الاسم في Auth + Firestore
  static Future<void> setDisplayName(String uid, String name) async {
    final trimmed = name.trim();
    if (trimmed.length < 2 || trimmed.length > 30) {
      throw Exception('الاسم لازم يكون بين 2 و 30 حرفاً.');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(trimmed);
      await user.reload();
    }

    await _users.doc(uid).set({
      'displayName': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
      'email': user?.email,
      'photoURL': user?.photoURL,
      'provider': 'google',
      'uid': uid,
    }, SetOptions(merge: true));
  }

  /// دايالوج إدخال/تعديل الاسم (مع تعبئة مسبقة)
  static Future<String?> _askForNameDialog(BuildContext context, {required String initial}) async {
    final controller = TextEditingController(text: initial);
    String? error;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('اختَر اسمك'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'مثال: تركي، أبو عزام',
                    errorText: error,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('سيظهر هذا الاسم داخل التطبيق.', style: TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  final v = controller.text.trim();
                  if (v.length < 2 || v.length > 30) {
                    setState(() => error = 'الاسم بين 2 و 30 حرفاً.');
                    return;
                  }
                  Navigator.of(ctx).pop(v);
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        });
      },
    );
  }
}
