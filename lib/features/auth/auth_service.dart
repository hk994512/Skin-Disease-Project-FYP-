import 'package:clearskin_ai/core/config.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentuser => instance._auth.currentUser;
  Future<User?> signUpWithEmail(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> displayUpdatedName(String displayName) {
    return _auth.currentUser!.updateDisplayName(displayName);
  }

  Future<void> reloadData() async {
    await _auth.currentUser?.reload();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
