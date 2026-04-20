import '/global/config.dart';

// in your providers file
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasSeenOnboarding') ?? false;
});

class OnboardingProviderNotifier extends StateNotifier<int> {
  OnboardingProviderNotifier() : super(0);

  final PageController pageController = PageController();

  void nextPage(int page) {
    state = page;
  }

  // In your OnboardingProviderNotifier
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

final onBoardProvider = StateNotifierProvider<OnboardingProviderNotifier, int>(
  (ref) => OnboardingProviderNotifier(),
);
