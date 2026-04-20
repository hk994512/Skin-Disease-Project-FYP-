import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../global/config.dart' hide User;

// Add this provider in your providers file
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = true;
  int _scanCount = 0; // ← now mutable, loaded from service

  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _reloadUser();
    _loadSavedImage();
    _loadScanCount(); // ← NEW
  }

  // Forces Firebase to fetch latest displayName / email / photoURL
  Future<void> _reloadUser() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  // ── NEW: Load real scan count from SkinAnalysisService ───────────────────────

  Future<void> _loadScanCount() async {
    try {
      final history = await SkinAnalysisService.instance.getScanHistory();
      if (mounted) setState(() => _scanCount = history.length);
    } catch (_) {
      if (mounted) setState(() => _scanCount = 0);
    }
  }

  // ── Profile image (SharedPreferences base64) ─────────────────────────────────

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString('profile_image');
    if (b64 == null || b64.isEmpty) return;
    final bytes = base64Decode(b64);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/profile_image.jpg');
    await file.writeAsBytes(bytes);
    if (mounted) setState(() => _selectedImage = file);
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', base64Encode(bytes));
    if (mounted) setState(() => _selectedImage = file);
  }

  // ── All data straight from FirebaseAuth.instance.currentUser ─────────────────

  String get _displayName {
    final name = _firebaseUser?.displayName ?? '';
    if (name.isNotEmpty) return name;
    final email = _firebaseUser?.email ?? '';
    if (email.contains('@')) return email.split('@').first;
    return 'Guest User';
  }

  String get _displayEmail => _firebaseUser?.email ?? 'guest@clearskin.ai';

  // ── UPDATED: Member since from Firebase Auth creation time ────────────────────

  String get _memberSince {
    final created = _firebaseUser?.metadata.creationTime;
    if (created == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[created.month - 1]} ${created.year}';
  }

  int get _skinScore =>
      _scanCount == 0 ? 0 : (70 + min(_scanCount * 3, 29)).clamp(0, 99).toInt();

  String get _skinScoreLabel {
    if (_skinScore == 0) return 'No data yet';
    if (_skinScore >= 90) return 'Excellent';
    if (_skinScore >= 75) return 'Good';
    if (_skinScore >= 60) return 'Fair';
    return 'Needs attention';
  }

  bool get _isLoggedIn => _firebaseUser != null;

  // ── Sign out ──────────────────────────────────────────────────────────────────

  Future<void> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go('/signIn');
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(text: context.locale.profile),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.colorScheme.primary,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(context),
                      SizedBox(height: 20.h),
                      Text(
                        'Skin Insights',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _FeatureItem(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Skin Score',
                        description: _scanCount > 0
                            ? '$_skinScore / 100 — $_skinScoreLabel'
                            : 'Complete your first scan to get a score',
                        color: context.colorScheme.primary,
                      ),
                      SizedBox(height: 12.h),
                      _FeatureItem(
                        icon: Icons.history_edu_rounded,
                        title: context.locale.scanHis,
                        // ✅ Real scan count from SkinAnalysisService
                        description:
                            '$_scanCount scan${_scanCount == 1 ? '' : 's'} completed',
                        color: context.colorScheme.secondary,
                      ),
                      SizedBox(height: 12.h),
                      _FeatureItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'Member Since',
                        // ✅ Real date from Firebase Auth metadata
                        description: _memberSince,
                        color: context.colorScheme.tertiary,
                      ),
                      SizedBox(height: 32.h),
                      _buildAuthButton(context),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────────

  Widget _buildHeroCard(BuildContext context) {
    final cs = context.colorScheme;

    ImageProvider? avatarImage;
    if (_selectedImage != null) {
      avatarImage = FileImage(_selectedImage!);
    } else if (_firebaseUser?.photoURL != null &&
        _firebaseUser!.photoURL!.isNotEmpty) {
      avatarImage = NetworkImage(_firebaseUser!.photoURL!);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _pickImageFromGallery,
                child: CircleAvatar(
                  radius: 52.r,
                  backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Text(
                          _displayName.isNotEmpty
                              ? _displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimary,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: cs.onPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 14.r,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            _displayName,
            style: context.textTheme.headlineSmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            _displayEmail,
            style: context.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: cs.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              // ✅ Both values are now live — scan count + Firebase date
              '$_scanCount ${context.locale.totalScans}${_scanCount == 1 ? '' : 's'}  ·  Since $_memberSince',
              style: context.textTheme.labelLarge?.copyWith(
                color: cs.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Auth button ───────────────────────────────────────────────────────────────

  Widget _buildAuthButton(BuildContext context) {
    final errorColor = context.colorScheme.error;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoggedIn ? _handleSignOut : () => context.go('/signIn'),
        icon: Icon(
          _isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
          size: 18.r,
          color: errorColor,
        ),
        label: Text(
          _isLoggedIn ? 'Sign Out' : 'Sign In',
          style: context.textTheme.titleSmall?.copyWith(
            color: errorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: BorderSide(color: errorColor.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
// ── _FeatureItem ──────────────────────────────────────────────────────────────

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 24.r),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── _QuickStatCard ────────────────────────────────────────────────────────────

// class _QuickStatCard extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;
//   final Color color;

//   const _QuickStatCard({
//     required this.icon,
//     required this.value,
//     required this.label,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Icon(icon, color: color, size: 28.r),
//           SizedBox(height: 12.h),
//           Text(
//             value,
//             style: context.textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             label,
//             style: context.textTheme.bodySmall?.copyWith(
//               color: context.colorScheme.onSurface.withValues(alpha: 0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
