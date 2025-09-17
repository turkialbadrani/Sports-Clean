import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    return userCred.user;
  }

  Future<void> saveDisplayName(String name) async {
    final box = Hive.box('user_prefs');
    await box.put('display_name', name);

    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': name,
        'photoUrl': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  String? getDisplayName() {
    final box = Hive.box('user_prefs');
    return box.get('display_name') as String?;
  }

  User? get currentUser => _auth.currentUser;
}
