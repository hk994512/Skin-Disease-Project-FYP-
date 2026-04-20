import '../global/config.dart';

final ass = AppAssets.instance;

class APPCOMMONS {
  APPCOMMONS._();
  static final instance = APPCOMMONS._();
  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      lottieAsset: ass.doctor,
      title: 'Welcome to Our App',
      description:
          'Discover amazing features and possibilities with our modern, intuitive platform.',
    ),
    OnboardingItem(
      lottieAsset: ass.ehealth,
      title: 'Powerful Features',
      description:
          'Access a wide range of tools designed to make your experience seamless and enjoyable.',
    ),
    OnboardingItem(
      lottieAsset: ass.specialist,
      title: 'Ready to Begin?',
      description:
          'Join thousands of satisfied users and start your journey with us today!',
    ),
  ];
  List<Map<String, dynamic>> homeItems = [
    {'lab': 'Scan', 'ico': ass.scan},
    {'lab': 'History', 'ico': ass.history},
    {'lab': 'Settings', 'ico': ass.settings},
    {'lab': 'Profile', 'ico': ass.profile},
  ];
}
