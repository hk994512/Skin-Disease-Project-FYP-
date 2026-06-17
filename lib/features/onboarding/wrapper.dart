import 'package:clearskin_ai/core/config.dart';

class WrapperScreen extends ConsumerWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);
    final user = FirebaseAuth.instance.currentUser;

    return hasSeenOnboarding.when(
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const OnboardingScreen(),
      data: (seen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!seen) {
            context.go('/onboarding');
          } else if (user == null) {
            context.go('/signIn');
          } else {
            context.go('/homeScreen');
          }
        });

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
