import '../global/config.dart';

class APPUTILS {
  APPUTILS._();
  static final APPUTILS instance = APPUTILS._();
  appSnackBar(BuildContext context, String message) {
    final theme = Theme.of(context);
    return context.showSnackBar(
      backgroundColor: theme.brightness != .dark
          ? theme.colorScheme.onPrimary
          : theme.colorScheme.surface,
      message: message,
      textStyle: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

extension AppLocales on BuildContext {
   AppLocalizations get locale => AppLocalizations.of(this)!;
}
