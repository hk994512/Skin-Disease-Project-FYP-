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
        shape: RoundedRectangleBorder(borderRadius: .circular(12.r)),
        margin: .all(16.w),
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
              padding: .all(16.w),
              children: [
                // ── Section header ────────────────────────────────────────
                _sectionLabel('PUSH NOTIFICATIONS', context),
                SizedBox(height: 8.h),
                // ── New Style tile ────────────────────────────────────────
                _NotifTile(
                  icon: Icons.style_outlined,
                  iconColor: primaryColor,
                  title: 'New Style',
                  subtitle: 'Get notified when new styles are added',
                  value: _newStyle,
                  onChanged: _onNewStyleChanged,
                ),
                SizedBox(height: 10.h),

                // ── Premium Benefits tile ─────────────────────────────────
                _NotifTile(
                  icon: Icons.workspace_premium_outlined,
                  iconColor: Colors.amber,
                  title: 'Premium Benefits',
                  subtitle: 'Exclusive deals, early access & member offers',
                  value: _premiumBenefits,
                  onChanged: _onPremiumBenefitsChanged,
                ),
                SizedBox(height: 24.h),

                // ── Premium Benefits info card ────────────────────────────
                if (_premiumBenefits) _buildPremiumInfoCard(context),

                SizedBox(height: 24.h),

                // ── Hint text ─────────────────────────────────────────────
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

  // ── Premium Benefits info card ─────────────────────────────────────────────
  Widget _buildPremiumInfoCard(BuildContext context) {
    final benefits = [
      _PremiumBenefit(
        icon: Icons.local_offer_outlined,
        title: 'Exclusive Discounts',
        desc: 'Up to 40% off on premium products — members only',
        color: Colors.orange,
      ),
      _PremiumBenefit(
        icon: Icons.rocket_launch_outlined,
        title: 'Early Access',
        desc: 'Be the first to try new features before public launch',
        color: Colors.blue,
      ),
      _PremiumBenefit(
        icon: Icons.card_giftcard_outlined,
        title: 'Monthly Rewards',
        desc: 'Earn points every month and redeem for free services',
        color: Colors.purple,
      ),
      _PremiumBenefit(
        icon: Icons.support_agent_outlined,
        title: 'Priority Support',
        desc: '24/7 dedicated support with faster response times',
        color: Colors.green,
      ),
      _PremiumBenefit(
        icon: Icons.wifi_protected_setup_outlined,
        title: 'Premium WiFi Profiles',
        desc: 'Auto-connect to trusted networks with saved credentials',
        color: Colors.teal,
      ),
      _PremiumBenefit(
        icon: Icons.bar_chart_outlined,
        title: 'Advanced Analytics',
        desc: 'Detailed usage stats, speed history & network reports',
        color: Colors.red,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('WHAT YOU\'LL RECEIVE', context),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: benefits.asMap().entries.map((entry) {
              final i = entry.key;
              final b = entry.value;
              return Column(
                children: [
                  _PremiumBenefitRow(benefit: b),
                  if (i < benefits.length - 1)
                    Divider(
                      height: 1,
                      indent: 56.w,
                      color: context.theme.dividerColor.withValues(alpha: 0.15),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
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

// ══════════════════════════════════════════════════════════════════════════════
// PREMIUM BENEFIT ROW
// ══════════════════════════════════════════════════════════════════════════════

class _PremiumBenefit {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _PremiumBenefit({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });
}

class _PremiumBenefitRow extends StatelessWidget {
  final _PremiumBenefit benefit;
  const _PremiumBenefitRow({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: benefit.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(benefit.icon, color: benefit.color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  benefit.desc,
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
