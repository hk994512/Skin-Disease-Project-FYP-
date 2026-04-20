import '/global/config.dart';

final GoRouter routerConfig = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  errorBuilder: (context, state) {
    return ErrorScreen();
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'wrapper',
      builder: (BuildContext context, GoRouterState state) {
        return const WrapperScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (BuildContext context, GoRouterState state) {
        return const SignupScreen();
      },
    ),
    GoRoute(
      path: '/signIn',
      name: 'signIn',
      builder: (BuildContext context, GoRouterState state) {
        return const SignInScreen();
      },
    ),
    GoRoute(
      path: '/homeScreen',
      name: 'homeScreen',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeBar();
      },
    ),
    GoRoute(
      path: '/scanScreen',
      name: 'scanScreen',
      builder: (BuildContext context, GoRouterState state) {
        return const ScanPage();
      },
    ),
    GoRoute(
      path: '/notificationScreen',
      name: 'notificationScreen',
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationSettings();
      },
    ),
    GoRoute(
      path: '/langs',
      name: 'languageScreen',
      builder: (_, _) {
        return const SelectLanguageScreen();
      },
    ),
    GoRoute(
      path: '/scanResult',
      name: 'scanResult',
      builder: (context, state) {
        final diseaseName = state.extra as String? ?? 'Unknown';
        return DiseaseDetailPage(diseaseName: diseaseName);
      },
    ),
    GoRoute(
      path: '/resPage',
      name: 'resPage',
      builder: (context, state) {
        final scanRes = state.extra as ScanResult;
        return ResultPage(scanResult: scanRes);
      },
    ),
  ],
);
