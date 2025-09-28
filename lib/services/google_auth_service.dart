// lib/services/google_auth_service.dart
// Google Sign-In (iOS) + Firebase Auth — بدون serverClientId لتفادي invalid_audience.
// يعتمد فقط على iOS CLIENT_ID الموجود في GoogleService-Info.plist.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // iOS client ID from GoogleService-Info.plist
  static const String _iosClientId = '253711866652-klmpti7fuf6puv31smpabeoc40uh6ljn.apps.googleusercontent.com';

  // GoogleSignIn مهيأة لـ iOS فقط
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _iosClientId,
    scopes: const ['email', 'openid', 'profile'],
  );

  /// تسجيل دخول تفاعلي (يعرض اختيار الحساب)
  static Future<UserCredential> signInWithGoogle() async {
    await _ensureFirebase();
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('تم إلغاء تسجيل الدخول.');
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// تسجيل صامت (بدون UI) إذا سبق وسجل المستخدم
  static Future<UserCredential?> signInSilently() async {
    await _ensureFirebase();
    final account = await _googleSignIn.signInSilently();
    if (account == null) return null;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// هل المستخدم مسجل دخول في FirebaseAuth ؟
  static bool get isFirebaseSignedIn => FirebaseAuth.instance.currentUser != null;

  /// هل فيه جلسة Google على الجهاز (قديمة)؟
  static Future<bool> isGoogleSignedIn() => _googleSignIn.isSignedIn();

  /// المستخدم الحالي (من Firebase)
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  /// الخروج
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }

  /// ستريم تغيّر حالة الدخول
  static Stream<User?> get onAuthChanges => FirebaseAuth.instance.authStateChanges();

  static Future<void> _ensureFirebase() async {
    try {
      // إذا ما هو مهيأ، هيئه
      Firebase.apps;
    } catch (_) {
      await Firebase.initializeApp();
    }
  }
}
