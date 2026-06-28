import '/core/config.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  Future<void> launchEmail(bool isEmail) async {
    final Uri uri = isEmail
        ? Uri(scheme: 'mailto', path: 'hamzakhan00561@gmail.com')
        : Uri.parse('https://github.com/hk994512/ClearSkin-AI');

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: isEmail
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
    } else {
      throw Exception(
        isEmail
            ? 'Could not launch email client.'
            : 'Could not open GitHub link.',
      );
    }
  }

  final AppAssets _asset = AppAssets.instance;
  final items = [
    {'lab': 'Light mode', 'ico': Icons.wb_sunny},
    {'lab': 'Dark mode', 'ico': Icons.dark_mode},
  ];
  showSheet() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Appearance',
              style: context.textTheme.headlineMedium!.copyWith(
                fontWeight: .bold,
              ),
            ),
          ),
          content: SizedBox(
            height: 103.h,
            child: Column(
              children: List.generate(items.length, (s) {
                final item = items[s];
                return Padding(
                  padding: .all(12.r),
                  child: GestureDetector(
                    onTap: () {
                      final isDark =
                          (item['lab'] as String).contains('Light mode')
                          ? true
                          : false;
                      ref.read(appThemeProvider.notifier).toggleTheme(isDark);
                      NavigatorExt(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: .spaceEvenly,
                      children: [
                        Text(
                          item['lab'] as String,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Icon(item['ico'] as IconData),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Wrap(
          spacing: 3,
          children: [
            Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
            const Text('ClearSkin AI'),
          ],
        ),
        content: Text(context.locale.aboutApp),
        actions: [
          TextButton(
            onPressed: () => NavigatorExt(context).pop(),
            child: Text(context.locale.close),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  _loadTheme() {
    return ref.read(appThemeProvider.notifier).loadThemeData();
  }

  String? selectedLang = 'English (US)';
  String? flag = '🇺🇸';
  stringBack() async {
    final LanguageItem? value = await NavigatorExt(context).push(
      settings: RouteSettings(name: selectedLang, arguments: flag),
      SelectLanguageScreen(),
    );
    if (value != null) {
      setState(() {
        selectedLang = value.name;
        flag = value.flag;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(text: context.locale.settings),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: .vertical,
          child: Padding(
            padding: .all(14.0.r),
            child: Column(
              children: [
                SettingsCard(
                  icon: _asset.theme,
                  title: context.locale.appear,
                  subtitle: context.locale.themeSub,
                  onTap: showSheet,
                ),
                // 12.heightBox,
                SizedBox(height: 12.h),
                SettingsCard(
                  icon: _asset.notification,
                  title: context.locale.noti,
                  subtitle: context.locale.manageNoti,
                  onTap: () {
                    GoRouterHelper(context).push('/notificationScreen');
                  },
                ),
                SizedBox(height: 12.h),
                SettingsCard(
                  icon: _asset.language,
                  title: context.locale.lang,
                  subtitle: selectedLang ?? '',
                  onTap: stringBack,
                ),
                SizedBox(height: 12.h),
                SettingsCard(
                  icon: _asset.share,
                  title: context.locale.share,
                  subtitle: context.locale.shareApp,
                  onTap: () {
                    launchEmail(false);
                  },
                ),
                SizedBox(height: 32.h),
                Text(
                  context.locale.about,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                // 16.heightBox,
                SizedBox(height: 16.h),
                SettingsCard(
                  icon: _asset.about,
                  title: 'About ClearSkin AI',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                SizedBox(height: 12.h),
                SettingsCard(
                  icon: _asset.privacy,
                  title: context.locale.privacyPoli,
                  subtitle: context.locale.howProtect,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => PrivacyPolicyDialog(),
                    );
                  },
                ),

                SizedBox(height: 12.h),
                SettingsCard(
                  icon: _asset.terms,
                  title: context.locale.terms,
                  subtitle: context.locale.legal,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => TermsOfServiceDialog(
                        onClose: () => Navigator.pop(context),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                SettingsCard(
                  icon: _asset.help,
                  title: context.locale.helpSupport,
                  subtitle: context.locale.getHelp,
                  onTap: () => launchEmail(true),
                ),
                SizedBox(height: 12.h),
                Text(
                  context.locale.exit,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: .bold,
                  ),
                ),
                16.heightBox,
                SettingsCard(
                  icon: _asset.exit,
                  title: context.locale.exitApp,
                  subtitle: context.locale.closeApp,
                  onTap: () => SystemNavigator.pop(animated: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
