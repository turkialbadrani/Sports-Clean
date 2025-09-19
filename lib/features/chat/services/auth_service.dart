import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>["email"],
    // على iOS لو عندك Client ID مخصص ممكن تحطه هنا:
    // clientId: "YOUR_IOS_CLIENT_ID.apps.googleusercontent.com",
  );

  Future<UserCredential?> signInWithGoogle() async {
    // يفتح نافذة تسجيل الدخول من Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // المستخدم لغى العملية

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }
}
