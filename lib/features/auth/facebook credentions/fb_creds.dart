import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/config.dart';

class FacebookAuthService {
  FacebookAuthService._();
  static final instance = FacebookAuthService._();

  Future<Map<String, dynamic>?> signIn() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // ✅ Step 1: Create Firebase credential from Facebook token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        // ✅ Step 2: Sign into Firebase with that credential
        await FirebaseAuth.instance.signInWithCredential(credential);

        // ✅ Step 3: Get Facebook user profile data
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)",
        );

        return userData;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Facebook signIn error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut(); // ✅ also sign out from Firebase
  }
}
