import 'package:clearskin_ai/core/config.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _newStyle = false;
  bool _premiumBenefits = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedStates();
  }

  Future<void> _loadSavedStates() async {
    final states = await NotificationService.instance.getSavedStates();
    if (!mounted) return;
    setState(() {
      _newStyle = states['notif_new_style'] ?? false;
      _premiumBenefits = states['notif_premium_benefits'] ?? false;
      _isLoading = false;
    });
  }

  Future<void> _onNewStyleChanged(bool value) async {
    setState(() => _newStyle = value);
    await NotificationService.instance.toggleNewStyle(value);
    if (!mounted) return;
    _showToast(
      value ? '🎨 New Style alerts enabled' : '🔕 New Style alerts disabled',
    );
  }

  Future<void> _onPremiumBenefitsChanged(bool value) async {
    setState(() => _premiumBenefits = value);
    await NotificationService.instance.togglePremiumBenefits(value);
    if (!mounted) return;
    _showToast(
      value
          ? '⭐ Premium Benefits alerts enabled'
          : '🔕 Premium Benefits alerts disabled',
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final primaryColor = isDark
        ? DarkModeColors.darkPrimary
        : LightModeColors.lightPrimary;

    return Scaffold(
      appBar: MyAppbar(
        text: context.locale.noti,
        automaticallyImplyLeading: true,
        fontWeight: FontWeight.w500,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                _sectionLabel('PUSH NOTIFICATIONS', context),
                SizedBox(height: 8.h),

                _NotifTile(
                  icon: Icons.style_outlined,
                  iconColor: primaryColor,
                  title: 'New Style',
                  subtitle: 'Get notified when new styles are added',
                  value: _newStyle,
                  onChanged: _onNewStyleChanged,
                ),
                SizedBox(height: 10.h),

                _NotifTile(
                  icon: Icons.workspace_premium_outlined,
                  iconColor: Colors.amber,
                  title: 'Premium Benefits',
                  subtitle: 'Exclusive deals, early access & member offers',
                  value: _premiumBenefits,
                  onChanged: _onPremiumBenefitsChanged,
                ),
                SizedBox(height: 24.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'You can change notification preferences at any time. '
                    'Make sure notifications are also enabled in your device settings.',
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.45,
                      ),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionLabel(String text, BuildContext context) {
    return Text(
      text,
      style: context.theme.textTheme.labelSmall?.copyWith(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.45),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE NOTIFICATION TILE
// ══════════════════════════════════════════════════════════════════════════════

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: value
              ? iconColor.withValues(alpha: 0.4)
              : context.theme.dividerColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        leading: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
        title: Text(
          title,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.theme.textTheme.bodySmall?.copyWith(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
            height: 1.4,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: iconColor,
        ),
      ),
    );
  }
}
