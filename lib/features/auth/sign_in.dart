import '/core/config.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with Validation, HandleSIGNIN, CurrentUserMixin, GoogleSignInMixin {
  final TextEditingController _emailController = .new();
  final TextEditingController _passwordController = .new();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final AppAssets _asset = AppAssets.instance;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkCurrentUser(context);
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      // handle error - see below
      rethrow;
    }
  }

  final fbInstance = FacebookAuthService.instance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: .all(24.0.r),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                SizedBox(height: 20.h),
                _buildAppBrand(context),
                SizedBox(height: 16.r.h),
                _buildWelcomeHeader(context),
                SizedBox(height: 40.h),
                _buildEmailField(context),
                SizedBox(height: 20.h),
                _buildPasswordField(context),
                SizedBox(height: 12.h),
                _buildForgotPasswordRow(context),
                SizedBox(height: 32.h),
                _buildLoginButton(context),
                SizedBox(height: 24.h),
                _buildSignUpFooter(context),
                SizedBox(height: 20.h),
                _buildOrDivider(context),
                SizedBox(height: 20.h),
                _buildSocialLoginButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBrand(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.inversePrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: .circular(16.r),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8.r,
                offset: Offset(0.w, 4.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'CS',
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: .bold, // Fixed: .bold to .bold
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.h),
        Text(
          'ClearSkin AI',
          style: context.theme.textTheme.headlineMedium?.copyWith(
            fontWeight: .bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.locale.welcome,
          style: GoogleFonts.montserrat(
            fontSize: 32.sp,
            fontWeight: .bold,
            color: colorScheme.onSurface,
          ),
        ),

        SizedBox(height: 8.h),
        Text(
          context.locale.signIntoContinue,
          style: GoogleFonts.montserrat(
            fontSize: 16.r.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.locale.emailAddress,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: .w500, // Fixed: .w500 to .w500
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.montserrat(
            fontSize: 16.r.sp,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'you@example.com',
            hintStyle: GoogleFonts.montserrat(
              fontSize: 16.r.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: colorScheme.primary,
              size: 22.r,
            ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            contentPadding: .symmetric(horizontal: 20.w, vertical: 16.h),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.locale.enterEmailReq;
            }
            if (!isValidEmail(value)) {
              return context.locale.enterValidEmail;
            }
            return null;
          },
        ),
      ],
    );
  }

  // Password Field Widget
  Widget _buildPasswordField(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.locale.password,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: .w500, // Fixed: .w500 to .w500
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '*********',
            hintStyle: GoogleFonts.montserrat(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: colorScheme.primary,
              size: 22.r,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 22.r,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(color: colorScheme.primary, width: 2.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(color: colorScheme.error, width: 1.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r), // Fixed
              borderSide: BorderSide(color: colorScheme.error, width: 2.w),
            ),
            contentPadding: .symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ), // Fixed: .symmetric to .symmetric
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Forgot Password & Remember Me Row
  Widget _buildForgotPasswordRow(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me Checkbox
        Row(
          children: [
            SizedBox(
              height: 24.h,
              width: 24.w,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: .circular(6.r),
                ), // Fixed
                activeColor: colorScheme.primary,
                checkColor: colorScheme.onPrimary,
                side: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  width: 1.5.w,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              context.locale.remember,
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),

        // Forgot Password Link
        // Forgot Password Link
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                final resetEmailController = TextEditingController(
                  text: _emailController.text.trim(),
                );
                bool isSending = false;

                return StatefulBuilder(
                  builder: (context, setDialogState) {
                    return AlertDialog(
                      title: const Text('Reset Password'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter your email and we\'ll send you a link to reset your password.',
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: resetEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'you@example.com',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: isSending
                              ? null
                              : () async {
                                  final email = resetEmailController.text
                                      .trim();
                                  if (email.isEmpty || !isValidEmail(email)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a valid email',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isSending = true);

                                  try {
                                    await sendPasswordReset(email);
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Password reset link sent. Check your inbox.',
                                          ),
                                        ),
                                      );
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    setDialogState(() => isSending = false);
                                    String message =
                                        'Something went wrong. Please try again.';
                                    if (e.code == 'invalid-email') {
                                      message =
                                          'Please enter a valid email address.';
                                    } else if (e.code == 'too-many-requests') {
                                      message =
                                          'Too many attempts. Please try again later.';
                                    }
                                    if (dialogContext.mounted) {
                                      ScaffoldMessenger.of(
                                        dialogContext,
                                      ).showSnackBar(
                                        SnackBar(content: Text(message)),
                                      );
                                    }
                                  }
                                },
                          child: isSending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Send Link'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: Text(
            'Forgot Password?',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: .w600,
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: colorScheme.primary.withValues(alpha: 0.5),
              decorationThickness: 1.5.r,
            ),
          ),
        ),
      ],
    );
  }

  // Login Button Widget
  Widget _buildLoginButton(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () {
          isLoading
              ? null
              : handleLogin(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: .circular(16.r)), // Fixed
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.6),
        ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                context.locale.signIn,
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: .w600,
                  color: colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  // Sign Up Footer Widget
  Widget _buildSignUpFooter(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.locale.dontAccount,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/signup'),
          child: Text(
            context.locale.signUp,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: .w600, // Fixed: .w600 to .w600
              color: colorScheme.primary,
              decorationColor: colorScheme.primary,
              decorationThickness: 2.r,
            ),
          ),
        ),
      ],
    );
  }

  // OR Divider Widget
  Widget _buildOrDivider(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            thickness: 1.r,
          ),
        ),
        Padding(
          padding: .symmetric(
            horizontal: 16.w,
          ), // Fixed: .symmetric to .symmetric
          child: Text(
            context.locale.or,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: .w500, // Fixed: .w500 to .w500
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            thickness: 1.r,
          ),
        ),
      ],
    );
  }

  // Social Login Buttons
  Widget _buildSocialLoginButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .center, // Fixed: .center to MainAxisAlignment.center
      children: [
        _buildSocialButton(
          context,
          icon: _asset.google,
          label: 'Google',
          onTap: () {
            signInWithGoogle();
          },
        ),
        // 16.r.widthBox,
        SizedBox(width: 16.w),
        _buildSocialButton(
          context,
          icon: _asset.facebook,
          label: 'Facebook',
          onTap: () async {
            try {
              final userData = await fbInstance.signIn();

              if (userData != null && context.mounted) {
                context.go('/homeScreen');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Facebook login failed: $e')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  // Individual Social Button
  Widget _buildSocialButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = context.theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: .symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: .circular(12.r),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                colorScheme.onSurface.withValues(alpha: 0.7),
                BlendMode.srcATop,
              ),
              // color: ,
              height: 20.h,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: .w500, // Fixed: .w500 to .w500
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
