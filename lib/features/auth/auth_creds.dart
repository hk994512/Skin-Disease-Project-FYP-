import 'package:clearskin_ai/core/config.dart';

mixin Validation {
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Include at least one number';
    }
    return null;
  }
}
mixin HandleSignUP<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final _auth = AuthService.instance;
  final _utils = APPUTILS.instance;
  // HandleSignUP — updated error codes
  Future<void> handleSignUp(
    String email,
    String password,
    String fullName,
  ) async {
    if (formKey.currentState!.validate()) {
      if (mounted) setState(() => isLoading = true);

      try {
        final user = await _auth.signUpWithEmail(email, password);
        if (user == null) throw Exception('Sign up failed');
        // Update displayName directly on the user object then reload
        await user.updateDisplayName(fullName);
        await user.reload();
        if (mounted) {
          setState(() => isLoading = false);
          _utils.appSnackBar(
            context,
            'Welcome, $fullName! Account created successfully!',
          );
          context.go('/signIn');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          _utils.appSnackBar(context, _getSignUpError(e.code));
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          _utils.appSnackBar(
            context,
            'An unexpected error occurred. Please try again.',
          );
        }
      }
    }
  }

  String _getSignUpError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password sign up is not enabled.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }
}
mixin HandleSIGNIN<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final _auth = AuthService.instance;
  final _util = APPUTILS.instance;
  // HandleSIGNIN — updated error codes
  Future<void> handleLogin(String email, String password) async {
    if (formKey.currentState!.validate()) {
      if (mounted) setState(() => isLoading = true);

      try {
        await _auth.signInWithEmail(email, password);
        if (mounted) {
          setState(() => isLoading = false);
          _util.appSnackBar(
            context,
            'Welcome back, ${_auth.currentuser?.displayName ?? 'User'}!',
          );
          context.go('/homeScreen'); // ✅ go() not goNamed()
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          _util.appSnackBar(context, _getSignInError(e.code));
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          _util.appSnackBar(context, 'An unexpected error occurred');
        }
      }
    }
  }

  String _getSignInError(String code) {
    switch (code) {
      case 'invalid-credential': // ✅ new combined code
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'user-not-found': // keep for older SDK fallback
        return 'No account found with this email.';
      case 'wrong-password': // keep for older SDK fallback
        return 'Incorrect password.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
mixin CurrentUserMixin {
  void checkCurrentUser(BuildContext c) {
    final auth = AuthService.instance;
    User? currentUser = auth.currentuser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (c.mounted) c.go('/homeScreen');
      });
    }
  }
}
mixin GoogleSignInMixin<T extends StatefulWidget> on State<T> {
  final u = APPUTILS.instance;
  bool isGoogleLoading = false;
  bool _googleInitialized = false;

  @override
  void initState() {
    super.initState();
    _configureGoogleSignIn();
  }

  Future<void> _configureGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            "493726548222-rma99kkn05rff1omd1lv2jof3qn5tgg9.apps.googleusercontent.com",
      );
      _googleInitialized = true;
    } catch (e) {
      debugPrint('Google Sign-In init error: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    if (isGoogleLoading) return;

    // ✅ Wait for init if not ready yet
    if (!_googleInitialized) {
      await _configureGoogleSignIn();
    }

    if (!mounted) return;
    setState(() => isGoogleLoading = true);

    try {
      // ✅ Step 1: Authenticate — get Google user
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      // ✅ Step 2: Get the ID token from authentication (NOT authorization)
      //    googleUser.authentication.idToken is the correct JWT Firebase needs
      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw Exception(
          'Failed to get ID token from Google. Check that serverClientId '
          'is set to your Web OAuth client ID.',
        );
      }

      // ✅ Step 3: Get client authorization for accessToken
      final GoogleSignInClientAuthorization clientAuth = await googleUser
          .authorizationClient
          .authorizeScopes(['email', 'profile', 'openid']);

      // ✅ Step 4: Build Firebase credential CORRECTLY
      //    idToken     → from googleUser.authentication.idToken
      //    accessToken → from clientAuth.accessToken
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: clientAuth.accessToken,
      );

      // ✅ Step 5: Sign in to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;
      setState(() => isGoogleLoading = false);
      u.appSnackBar(
        context,
        'Welcome, ${userCredential.user?.displayName ?? 'User'}!',
      );
      context.go('/homeScreen');
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      setState(() => isGoogleLoading = false);
      final msg = e.code == GoogleSignInExceptionCode.canceled
          ? 'Sign in cancelled.'
          : 'Google error: ${e.description}';
      u.appSnackBar(context, msg);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isGoogleLoading = false);
      u.appSnackBar(context, e.message ?? 'Firebase sign-in failed.');
    } catch (e) {
      if (!mounted) return;
      setState(() => isGoogleLoading = false);
      u.appSnackBar(context, 'Error: ${e.toString()}');
    }
  }
}

// mixin FacebookSignInMixin<T extends StatefulWidget> on State<T> {
//   final u = APPUTILS.instance;
//   bool isFacebookLoading = false;

//   Future<void> signInWithFacebook() async {
//     if (isFacebookLoading) return;

//     if (!mounted) return;
//     setState(() => isFacebookLoading = true);

//     try {
//       // Step 1: Trigger Facebook login flow
//       final LoginResult result = await FacebookAuth.instance.login(
//         permissions: ['email', 'public_profile'],
//       );

//       if (result.status != LoginStatus.success) {
//         if (!mounted) return;
//         setState(() => isFacebookLoading = false);

//         final msg = result.status == LoginStatus.cancelled
//             ? 'Sign in cancelled.'
//             : 'Facebook error: ${result.message ?? "Unknown error"}';
//         u.appSnackBar(context, msg);
//         return;
//       }

//       // Step 2: Get the access token
//       final accessToken = result.accessToken;
//       if (accessToken == null) {
//         throw Exception('Failed to get Facebook access token.');
//       }

//       // Step 3: Build Firebase credential
//       final credential = FacebookAuthProvider.credential(
//         accessToken.tokenString,
//       );

//       // Step 4: Sign in to Firebase
//       final userCredential = await FirebaseAuth.instance.signInWithCredential(
//         credential,
//       );

//       if (!mounted) return;
//       setState(() => isFacebookLoading = false);
//       u.appSnackBar(
//         context,
//         'Welcome, ${userCredential.user?.displayName ?? 'User'}!',
//       );
//       context.go('/homeScreen');
//     } on FirebaseAuthException catch (e) {
//       if (!mounted) return;
//       setState(() => isFacebookLoading = false);
//       u.appSnackBar(context, e.message ?? 'Firebase sign-in failed.');
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isFacebookLoading = false);
//       u.appSnackBar(context, 'Error: ${e.toString()}');
//     }
//   }
// }
