class AppAssets {
  AppAssets._();
  static final instance = AppAssets._();
  String history = assetHandler('history.svg');
  String profile = assetHandler('profile.svg');
  String scan = assetHandler('scan.svg');
  String settings = assetHandler('settings.svg');
  String doctor = assetHandler('doctor.json');
  String ehealth = assetHandler('ehealth.json');
  String specialist = assetHandler('specialist.json');
  String camera = assetHandler('camera.svg');
  String facebook = assetHandler('facebook.svg');
  String google = assetHandler('google.svg');
  //
  String theme = assetHandler('theme.svg');
  String notification = assetHandler('notifications.svg');
  String language = assetHandler('language.svg');
  String share = assetHandler('share.svg');
  String about = assetHandler('about.svg');
  String privacy = assetHandler('privacy.svg');
  String terms = assetHandler('terms.svg');
  String help = assetHandler('help.svg');
  String exit = assetHandler('exit.svg');
}

String assetHandler(String asset) {
  const base = 'assets/';
  return '$base$asset';
}
