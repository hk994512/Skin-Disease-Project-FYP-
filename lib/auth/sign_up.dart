import '../global/config.dart' hide User;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with Validation, HandleSignUP {
  final TextEditingController _fullNameController = .new();
  final TextEditingController _emailController = .new();
  final TextEditingController _passwordController = .new();
  final TextEditingController _confirmPasswordController = .new();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void>? selectHandler() {
    return isLoading
        ? null
        : handleSignUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _fullNameController.text.trim(),
          );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: .all(24.r),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(context),
                SizedBox(height: 40.h),
                // Form Fields Section
                _buildFullNameField(context),
                SizedBox(height: 20.h),
                _buildEmailField(context),
                SizedBox(height: 20.h),
                _buildPasswordField(context),
                SizedBox(height: 20.h),
                _buildConfirmPasswordField(context),
                SizedBox(height: 32.h),
                _buildSignUpButton(context),
                SizedBox(height: 24.h),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.locale.createAccount,
          // 'Create Account',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 32.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          context.locale.signUpStart,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }

  // Full Name Field
  Widget _buildFullNameField(BuildContext context) {
    // final theme = Theme.of(context);
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.locale.fullName,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _fullNameController,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'M Hamza',
            hintStyle: GoogleFonts.montserrat(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.person_outline_rounded,
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
              borderRadius: .circular(16.r),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(16.w),
              borderSide: BorderSide(color: colorScheme.primary, width: 2.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2.w),
            ),
            contentPadding: .symmetric(horizontal: 20.w, vertical: 16.h),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.locale.pleaseEnter;
            }
            if (value.trim().split(' ').length < 2) {
              return context.locale.pleaseEnterBoth;
            }
            return null;
          },
        ),
      ],
    );
  }

  // Email Field
  Widget _buildEmailField(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.locale.email,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: .w500,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'you@example.com',
            hintStyle: GoogleFonts.montserrat(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: .circular(16),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: .circular(16),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: .circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 1.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: .circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 2.w),
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

  // Password Field
  Widget _buildPasswordField(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.locale.password,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: .w500,
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
            hintText: '**********',
            hintStyle: GoogleFonts.montserrat(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 22,
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
              borderRadius: .circular(16.r),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2.w),
            ),
            contentPadding: .symmetric(horizontal: 20.w, vertical: 16.h),
          ),
          validator: (value) => validatePassword(value ?? ''),
        ),
      ],
    );
  }

  // Confirm Password Field
  Widget _buildConfirmPasswordField(BuildContext context) {
    // final theme = Theme.of(context);
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.locale.confirmPassword,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: .w500,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),

        SizedBox(height: 8.h),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '**********',
            hintStyle: GoogleFonts.montserrat(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
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
              borderRadius: .circular(16.r),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: .circular(16.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2.w),
            ),
            contentPadding: .symmetric(horizontal: 20.w, vertical: 16.h),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.locale.confirmPasswordReq;
            }
            if (value != _passwordController.text) {
              return context.locale.password2ntMatch;
            }
            return null;
          },
        ),
      ],
    );
  }

  // Sign Up Button
  Widget _buildSignUpButton(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return SizedBox(
      width: .infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: selectHandler,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: .circular(16.r)),
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
                context.locale.signUp,
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: .w600,
                  color: colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  // Footer with Login Redirect
  Widget _buildFooter(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Row(
      mainAxisAlignment: .center,
      children: [
        Text(
          context.locale.alreadyAccount,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        GestureDetector(
          onTap: () {
            context.go('/signIn');
          },
          child: Text(
            context.locale.signIn,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: .w600,
              color: colorScheme.primary,
              decorationColor: colorScheme.primary,
              decorationThickness: 2,
            ),
          ),
        ),
      ],
    );
  }
}
