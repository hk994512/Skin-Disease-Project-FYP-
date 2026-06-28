// ignore_for_file: unused_import
export 'package:url_launcher/url_launcher.dart';
export 'package:device_info_plus/device_info_plus.dart';
export 'package:permission_handler/permission_handler.dart';
// ─── Flutter & Core ───────────────────────────────────────────
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter/gestures.dart';
export 'dart:io';
export 'dart:convert';
export 'dart:math' show min;
export 'dart:typed_data';

// ─── Firebase ─────────────────────────────────────────────────
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart'
    show
        FirebaseAuth,
        UserCredential,
        User,
        FirebaseAuthException,
        GoogleAuthProvider;
export 'package:firebase_messaging/firebase_messaging.dart'
    show RemoteMessage, FirebaseMessaging, AuthorizationStatus;
export '../firebase_options.dart';

// ─── State management ─────────────────────────────────────────
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:flutter_riverpod/legacy.dart';

// ─── Routing ──────────────────────────────────────────────────
export 'package:go_router/go_router.dart'
    show GoRouter, GoRouterState, GoRoute, GoRouterHelper;
export './routes.dart';
export '../shared/models/onboarding_item.dart';
// ─── UI & Design ──────────────────────────────────────────────
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_svg/svg.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:lottie/lottie.dart';
export 'package:awesome_extensions/awesome_extensions.dart'
    show
        NavigatorExt,
        ThemeExt,
        MediaQueryExt,
        ColorSchemeExt,
        SnackbarExt,
        SizeBoxNumExtension;

// ─── Localizations ────────────────────────────────────────────
export 'package:flutter_localizations/flutter_localizations.dart';
export '../l10n/app_localizations.dart' show AppLocalizations;

// ─── Google Sign-In ───────────────────────────────────────────
export 'package:google_sign_in/google_sign_in.dart';

// ─── Storage & Preferences ────────────────────────────────────
export 'package:shared_preferences/shared_preferences.dart';
export 'package:path_provider/path_provider.dart';

// ─── Networking ───────────────────────────────────────────────
export 'package:http/http.dart'
    show MultipartRequest, MultipartFile, Response, StreamedResponse;
export 'package:http_parser/http_parser.dart' show MediaType;

// ─── Image & File ─────────────────────────────────────────────
export 'package:image_picker/image_picker.dart';
export 'package:image/image.dart' show decodeImage, copyResize;
export 'package:open_file/open_file.dart';

// ─── AI / TFLite ──────────────────────────────────────────────
export 'package:tflite_flutter/tflite_flutter.dart';

// ─── PDF ──────────────────────────────────────────────────────
export 'package:pdf/pdf.dart';
export 'package:printing/printing.dart';

// ─── Utilities ────────────────────────────────────────────────
export 'package:uuid/uuid.dart';
export 'package:intl/intl.dart' show DateFormat;
export 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─── App Core ─────────────────────────────────────────────────
export '../theme.dart';
export '../constants/commons.dart';
export '../constants/app_assets.dart';
export './error_screen.dart';
export './app_utils.dart';
export './notifications/notification_service.dart';
export './notifications/notification_settings.dart';

// ─── App Features ─────────────────────────────────────────────
export '../features/onboarding/wrapper.dart';
export '../features/onboarding/onboarding_screen.dart';
export '../features/home/home_page.dart';
export '../features/auth/auth_service.dart';
export '../features/auth/auth_creds.dart';
export 'package:clearskin_ai/features/auth/sign_in.dart';
export 'package:clearskin_ai/features/auth/sign_up.dart';
export '../features/scan/skin_analysis_service.dart';
export '../features/scan/result_page.dart';
export '../features/scan/disease_chat_sheet.dart';
export '../features/scan/disease_detail_page.dart';
export '../features/scan/diseases_info_service.dart';
 export '../features/scan/scan_page.dart';

export '../features/scan/pdf_report_service.dart';
export '../features/history/history_page.dart';
export '../features/profile/profile_page.dart';
export '../features/profile/settings_screen.dart';
export '../features/profile/user_service.dart';

// ─── Shared Models ────────────────────────────────────────────
export '../shared/models/user.dart';
export '../shared/models/scan_result.dart';
export '../shared/models/disease_info.dart';
export '../shared/models/language_item.dart';

// ─── Shared Providers ─────────────────────────────────────────
export '../shared/providers/theme_provider.dart';
export '../shared/providers/home_provider.dart';
export '../shared/providers/lang_provider.dart';
export '../shared/providers/onboarding_provider.dart';

// ─── Shared Widgets ───────────────────────────────────────────
export '../shared/widgets/my_appbar.dart';
export '../shared/widgets/confidence_meter.dart';
export '../shared/widgets/loading_overlay.dart';
export '../shared/widgets/scan_history_card.dart';
export '../shared/widgets/settings_item.dart';
export '../shared/widgets/treatment_card.dart';
export '../shared/widgets/privacy_policy.dart';
export '../shared/widgets/about/terms_services.dart';

// ─── Language ─────────────────────────────────────────────────
export '../language/lang_settings.dart';

/// Facebook Authentication
export '/features/auth/facebook%20credentions/fb_creds.dart';
export 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
