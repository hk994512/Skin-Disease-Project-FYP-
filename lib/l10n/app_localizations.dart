import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get started;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpStart.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signUpStart;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @hintText.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get hintText;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnter;

  /// No description provided for @pleaseEnterBoth.
  ///
  /// In en, this message translates to:
  /// **'Please enter both first and last name'**
  String get pleaseEnterBoth;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmailReq.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmailReq;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordReq.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordReq;

  /// No description provided for @password2ntMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password2ntMatch;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcome;

  /// No description provided for @signIntoContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signIntoContinue;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @remember.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember;

  /// No description provided for @dontAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontAccount;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @healthCompainion.
  ///
  /// In en, this message translates to:
  /// **'Your AI Skin Health Companion'**
  String get healthCompainion;

  /// No description provided for @detectPic.
  ///
  /// In en, this message translates to:
  /// **'Take or upload a photo to detect potential skin conditions instantly'**
  String get detectPic;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get features;

  /// No description provided for @instantAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Instant Analysis'**
  String get instantAnalysis;

  /// No description provided for @getResults.
  ///
  /// In en, this message translates to:
  /// **'Get results in seconds with AI-powered detection'**
  String get getResults;

  /// No description provided for @accuDet.
  ///
  /// In en, this message translates to:
  /// **'Accurate Detection'**
  String get accuDet;

  /// No description provided for @advancedMl.
  ///
  /// In en, this message translates to:
  /// **'Advanced ML models trained on medical data'**
  String get advancedMl;

  /// No description provided for @treatGuide.
  ///
  /// In en, this message translates to:
  /// **'Treatment Guidance'**
  String get treatGuide;

  /// No description provided for @receiveTreat.
  ///
  /// In en, this message translates to:
  /// **'Receive personalized treatment recommendations'**
  String get receiveTreat;

  /// No description provided for @infoApp.
  ///
  /// In en, this message translates to:
  /// **'This app is for informational purposes only. Always consult a healthcare professional for medical advice.'**
  String get infoApp;

  /// No description provided for @scanSkin.
  ///
  /// In en, this message translates to:
  /// **'Scan Skin Condition'**
  String get scanSkin;

  /// No description provided for @uploadCapturePic.
  ///
  /// In en, this message translates to:
  /// **'Upload or Capture Photo'**
  String get uploadCapturePic;

  /// No description provided for @effectedAreaPic.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of the affected skin area'**
  String get effectedAreaPic;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImage;

  /// No description provided for @analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze Image'**
  String get analyze;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips for Best Results'**
  String get tips;

  /// No description provided for @goodLight.
  ///
  /// In en, this message translates to:
  /// **'Ensure good lighting'**
  String get goodLight;

  /// No description provided for @focusClearly.
  ///
  /// In en, this message translates to:
  /// **'Focus clearly on the affected area'**
  String get focusClearly;

  /// No description provided for @avoidShadows.
  ///
  /// In en, this message translates to:
  /// **'Avoid shadows or reflections'**
  String get avoidShadows;

  /// No description provided for @steadyCam.
  ///
  /// In en, this message translates to:
  /// **'Keep the camera steady'**
  String get steadyCam;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing skin condition'**
  String get analyzing;

  /// No description provided for @anaRes.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get anaRes;

  /// No description provided for @detectCondition.
  ///
  /// In en, this message translates to:
  /// **'Detected Condition'**
  String get detectCondition;

  /// No description provided for @des.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get des;

  /// No description provided for @comSym.
  ///
  /// In en, this message translates to:
  /// **'Common Symptoms'**
  String get comSym;

  /// No description provided for @recoTreat.
  ///
  /// In en, this message translates to:
  /// **'Recommended Treatments'**
  String get recoTreat;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More About This Condition'**
  String get learnMore;

  /// No description provided for @aiGen.
  ///
  /// In en, this message translates to:
  /// **'This is an AI-generated result. Please consult a dermatologist for professional diagnosis and treatment.'**
  String get aiGen;

  /// No description provided for @delScan.
  ///
  /// In en, this message translates to:
  /// **'Scan deleted successfully'**
  String get delScan;

  /// No description provided for @scanHis.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHis;

  /// No description provided for @noHist.
  ///
  /// In en, this message translates to:
  /// **'No Scan History'**
  String get noHist;

  /// No description provided for @prevScan.
  ///
  /// In en, this message translates to:
  /// **'Your previous skin scans will appear here'**
  String get prevScan;

  /// No description provided for @appear.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appear;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'ClearSkin AI is an advanced skin disease detection application powered by artificial intelligence. Our mission is to make dermatological insights accessible to everyone.\n\nVersion: 1.0.0\n\n'**
  String get aboutApp;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @themeSub.
  ///
  /// In en, this message translates to:
  /// **'Theme follows system settings'**
  String get themeSub;

  /// No description provided for @noti.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get noti;

  /// No description provided for @manageNoti.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get manageNoti;

  /// No description provided for @lang.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lang;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share application'**
  String get share;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Please share our app to friends & family memebers'**
  String get shareApp;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPoli.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPoli;

  /// No description provided for @howProtect.
  ///
  /// In en, this message translates to:
  /// **'How we protect your data'**
  String get howProtect;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal terms and conditions'**
  String get legal;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help or contact us'**
  String get getHelp;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @closeApp.
  ///
  /// In en, this message translates to:
  /// **'Press to close app'**
  String get closeApp;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @totalScans.
  ///
  /// In en, this message translates to:
  /// **'Total Scan'**
  String get totalScans;

  /// No description provided for @since.
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get since;

  /// No description provided for @scans.
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get scans;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @selectLang.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLang;

  /// No description provided for @disInfo.
  ///
  /// In en, this message translates to:
  /// **'Disease Information'**
  String get disInfo;

  /// No description provided for @infoUnavil.
  ///
  /// In en, this message translates to:
  /// **'Information Not Available'**
  String get infoUnavil;

  /// No description provided for @infoDetailsUnavail.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find detailed information for this condition.'**
  String get infoDetailsUnavail;

  /// No description provided for @overView.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overView;

  /// No description provided for @symptom.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptom;

  /// No description provided for @causes.
  ///
  /// In en, this message translates to:
  /// **'Causes'**
  String get causes;

  /// No description provided for @treatments.
  ///
  /// In en, this message translates to:
  /// **'Treatments'**
  String get treatments;

  /// No description provided for @prevents.
  ///
  /// In en, this message translates to:
  /// **'Preventions'**
  String get prevents;

  /// No description provided for @alwayConsult.
  ///
  /// In en, this message translates to:
  /// **'Always consult with a healthcare professional for accurate diagnosis and personalized treatment plans.'**
  String get alwayConsult;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get wait;

  /// No description provided for @deleteScan.
  ///
  /// In en, this message translates to:
  /// **'Delete Scan'**
  String get deleteScan;

  /// No description provided for @areUSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this scan result?'**
  String get areUSure;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'pt',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
