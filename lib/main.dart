import './global/config.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appThemeProvider);
    final currentTheme = !isDarkMode ? darkTheme : lightTheme;
    final selectedLang = ref.watch(langPro);
    final locale = selectedLang;

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'ClearSkin AI',
          debugShowCheckedModeBanner: false,
          theme: currentTheme,
          darkTheme: currentTheme,
          locale: locale,
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('de'),
            Locale('fr'),
            Locale('hi'),
            Locale('id'),
            Locale('pt'),
            Locale('ru'),
            Locale('tr'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: routerConfig,
        );
      },
    );
  }
}
