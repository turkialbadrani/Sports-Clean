// lib/services/google_auth_service.dart
// Google Sign-In + Firebase Auth
// - Android: بدون clientId.
// - iOS: نمرّر iOS clientId فقط.
// - تسجيل صامت متاح.
// - تهيئة Firebase عند الحاجة.
// - واجهات الاستخدام تكون "static" فقط:
//     GoogleAuthService.signInSilentlyIfPossible();
//     GoogleAuthService.signInWithGoogle();
//     GoogleAuthService.signOut();

import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../firebase_options.dart';

class GoogleAuthService {
  GoogleAuthService._internal() {
    // نهيّئ GoogleSignIn مرّة واحدة حسب المنصّة (بدون const)
    _googleSignIn = Platform.isIOS
        ? GoogleSignIn(
            clientId: _iosClientId,
            scopes: const ['email', 'openid', 'profile'],
          )
        : GoogleSignIn(
            scopes: const ['email', 'openid', 'profile'],
          );
  }

  static final GoogleAuthService instance = GoogleAuthService._internal();

  // iOS client ID (من GoogleService-Info.plist)
  static const String _iosClientId =
      '253711866652-klmpti7fuf6puv31smpabeoc40uh6ljn.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===================== PRIVATE instance API =====================
  // نخليها خاصة عشان ما تتعارض مع الواجهات الستاتيكية بنفس الأسماء.

  Future<User?> _signInSilentlyIfPossible() async {
    await _ensureFirebase();

    if (_auth.currentUser != null) return _auth.currentUser;

    final GoogleSignInAccount? acc = await _googleSignIn.signInSilently();
    if (acc == null) return null;

    final GoogleSignInAuthentication gAuth = await acc.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    return cred.user;
  }

  Future<UserCredential> _signInWithGoogle() async {
    await _ensureFirebase();

    final GoogleSignInAccount? acc = await _googleSignIn.signIn();
    if (acc == null) {
      throw Exception('Sign-in cancelled.');
    }

    final GoogleSignInAuthentication gAuth = await acc.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> _signOut() async {
    try {
      await _googleSignIn.signOut();
    } finally {
      await _auth.signOut();
    }
  }

  Stream<User?> get _onAuthChanges => _auth.authStateChanges();
  User? get _currentUser => _auth.currentUser;

  // تهيئة Firebase لو ما تهيّأ (مع تجاوز duplicate-app)
  Future<void> _ensureFirebase() async {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (e) {
        if (e.code != 'duplicate-app') rethrow;
      }
    }
  }

  // ===================== PUBLIC static API =====================
  // هذه فقط اللي نستخدمها بباقي المشروع.

  static Future<User?> signInSilentlyIfPossible() =>
      instance._signInSilentlyIfPossible();

  static Future<UserCredential> signInWithGoogle() =>
      instance._signInWithGoogle();

  static Future<void> signOut() => instance._signOut();

  static Stream<User?> get onAuthChangesStream => instance._onAuthChanges;
  static User? get currentUserStatic => instance._currentUser;
}
