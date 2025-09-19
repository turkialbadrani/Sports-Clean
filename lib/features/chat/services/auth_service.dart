import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String? getDisplayName() => currentUser?.displayName;

  Future<void> saveDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
    }
  }

  /// Google Sign-In بدون حزمة google_sign_in
  /// - iOS/Android: signInWithProvider
  /// - Web: signInWithPopup
  Future<UserCredential?> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    try {
      if (kIsWeb) {
        return await _auth.signInWithPopup(provider);
      } else {
        return await _auth.signInWithProvider(provider);
      }
    } catch (e) {
      // تقدر تطبع الخطأ لو حاب
      // debugPrint('Google sign-in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // ما نحتاج نستدعي google_sign_in.signOut لأننا ما نستخدمها أصلاً
  }
}
