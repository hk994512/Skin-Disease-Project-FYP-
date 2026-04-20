import '../global/config.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  // Topic names — must match exactly what you send from Firebase Console
  static const String kTopicNewStyle = 'new_style';
  static const String kTopicPremiumBenefits = 'premium_benefits';

  // SharedPreferences keys
  static const String _keyNewStyle = 'notif_new_style';
  static const String _keyPremiumBenefits = 'notif_premium_benefits';

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // 1. Request permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _initLocalNotifications();
      await _restoreTopicSubscriptions();
      _listenForeground();
    }
  }

  // ── Local notifications setup ────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'easyconnect_channel',
      'EasyConnect Notifications',
      description: 'App notifications for new styles and premium benefits',
      importance: .high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // ── Show notification when app is in foreground ───────────────────────────

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'clearskin_channel',
            'ClearSkin Notifications',
            channelDescription: 'App notifications',
            importance: .high,
            priority: .high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['route'],
      );
    });
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle navigation when user taps notification
    // e.g. navigatorKey.currentState?.pushNamed(response.payload ?? '/');
  }

  // ── Topic subscription helpers ────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // ── Restore saved preferences on app launch ───────────────────────────────

  Future<void> _restoreTopicSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();

    final newStyleOn = prefs.getBool(_keyNewStyle) ?? false;
    final premiumBenefitsOn = prefs.getBool(_keyPremiumBenefits) ?? false;

    if (newStyleOn) {
      await subscribeToTopic(kTopicNewStyle);
    }
    if (premiumBenefitsOn) {
      await subscribeToTopic(kTopicPremiumBenefits);
    }
  }

  // ── Toggle helpers (called from UI) ──────────────────────────────────────

  Future<void> toggleNewStyle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNewStyle, value);
    value
        ? await subscribeToTopic(kTopicNewStyle)
        : await unsubscribeFromTopic(kTopicNewStyle);
  }

  Future<void> togglePremiumBenefits(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPremiumBenefits, value);
    value
        ? await subscribeToTopic(kTopicPremiumBenefits)
        : await unsubscribeFromTopic(kTopicPremiumBenefits);
  }

  // ── Read saved state ──────────────────────────────────────────────────────

  Future<Map<String, bool>> getSavedStates() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _keyNewStyle: prefs.getBool(_keyNewStyle) ?? false,
      _keyPremiumBenefits: prefs.getBool(_keyPremiumBenefits) ?? false,
    };
  }

  // ── Get FCM token (useful for targeted push) ──────────────────────────────

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
