import './global/config.dart';

class LightModeColors {
  static const lightPrimary = Color(0xFF00ACC1);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFB2EBF2);
  static const lightOnPrimaryContainer = Color(0xFF006064);
  static const lightSecondary = Color(0xFF4CAF50);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightTertiary = Color(0xFFFF6B6B);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightError = Color(0xFFE53935);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF5F0A0D);
  static const lightInversePrimary = Color(0xFF4DD0E1);
  static const lightShadow = Color(0xFF000000);
  static const lightSurface = Color(0xFFFAFAFA);
  static const lightOnSurface = Color(0xFF1A1A1A);
  static const lightAppBarBackground = Color(0xFFFFFFFF);
  static const lightSuccessColor = Color(0xFF4CAF50);
  static const lightWarningColor = Color(0xFFFF9800);
}

class DarkModeColors {
  static const darkPrimary = Color(0xFF4DD0E1);
  static const darkOnPrimary = Color(0xFF00363A);
  static const darkPrimaryContainer = Color(0xFF00838F);
  static const darkOnPrimaryContainer = Color(0xFFE0F7FA);
  static const darkSecondary = Color(0xFF81C784);
  static const darkOnSecondary = Color(0xFF1B5E20);
  static const darkTertiary = Color(0xFFFF8A80);
  static const darkOnTertiary = Color(0xFF5F0A0D);
  static const darkError = Color(0xFFEF5350);
  static const darkOnError = Color(0xFF370A0B);
  static const darkErrorContainer = Color(0xFFC62828);
  static const darkOnErrorContainer = Color(0xFFFFCDD2);
  static const darkInversePrimary = Color(0xFF00ACC1);
  static const darkShadow = Color(0xFF000000);
  static const darkSurface = Color(0xFF0A1929);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkAppBarBackground = Color(0xFF0D2137);
  static const darkSuccessColor = Color(0xFF81C784);
  static const darkWarningColor = Color(0xFFFFB74D);
}

class FontSizes {
  static const  double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static  const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static  const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static  const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    inversePrimary: LightModeColors.lightInversePrimary,
    shadow: LightModeColors.lightShadow,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
  ),
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: LightModeColors.lightAppBarBackground,
    foregroundColor: LightModeColors.lightOnPrimaryContainer,
    elevation: 0,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.displayLarge,
      fontWeight: .normal,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.displayMedium,
      fontWeight: .normal,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: FontSizes.displaySmall,
      fontWeight: .w600,
    ),
    headlineLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.headlineLarge,
      fontWeight: .normal,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.headlineMedium,
      fontWeight: .w500,
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontSize: FontSizes.headlineSmall,
      fontWeight: .bold,
    ),
    titleLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.titleLarge,
      fontWeight: .w500,
    ),
    titleMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.titleMedium,
      fontWeight: .w500,
    ),
    titleSmall: GoogleFonts.montserrat(
      fontSize: FontSizes.titleSmall,
      fontWeight: .w500,
    ),
    labelLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.labelLarge,
      fontWeight: .w500,
    ),
    labelMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.labelMedium,
      fontWeight: .w500,
    ),
    labelSmall: GoogleFonts.montserrat(
      fontSize: FontSizes.labelSmall,
      fontWeight: .w500,
    ),
    bodyLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.bodyLarge,
      fontWeight: .normal,
    ),
    bodyMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.bodyMedium,
      fontWeight: .normal,
    ),
    bodySmall: GoogleFonts.montserrat(
      fontSize: FontSizes.bodySmall,
      fontWeight: .normal,
    ),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    inversePrimary: DarkModeColors.darkInversePrimary,
    shadow: DarkModeColors.darkShadow,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
  ),
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: DarkModeColors.darkAppBarBackground,
    foregroundColor: DarkModeColors.darkOnPrimaryContainer,
    elevation: 0,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.displayLarge,
      fontWeight: .normal,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.displayMedium,
      fontWeight: .normal,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: FontSizes.displaySmall,
      fontWeight: .w600,
    ),
    headlineLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.headlineLarge,
      fontWeight: .normal,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.headlineMedium,
      fontWeight: .w500,
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontSize: FontSizes.headlineSmall,
      fontWeight: .bold,
    ),
    titleLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.titleLarge,
      fontWeight: .w500,
    ),
    titleMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.titleMedium,
      fontWeight: .w500,
    ),
    titleSmall: GoogleFonts.montserrat(
      fontSize: FontSizes.titleSmall,
      fontWeight: .w500,
    ),
    labelLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.labelLarge,
      fontWeight: .w500,
    ),
    labelMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.labelMedium,
      fontWeight: .w500,
    ),
    labelSmall: GoogleFonts.montserrat(
      fontSize: FontSizes.labelSmall,
      fontWeight: .w500,
    ),
    bodyLarge: GoogleFonts.montserrat(
      fontSize: FontSizes.bodyLarge,
      fontWeight: .normal,
    ),
    bodyMedium: GoogleFonts.montserrat(
      fontSize: FontSizes.bodyMedium,
      fontWeight: .normal,
    ),
    bodySmall: GoogleFonts.montserrat(
      fontSize: FontSizes.bodySmall,
      fontWeight: .normal,
    ),
  ),
);
