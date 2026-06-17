import 'package:clearskin_ai/core/config.dart';

class LangProviderNotifier extends StateNotifier<Locale> {
  LangProviderNotifier() : super(Locale('en'));
  handleLang(Locale loc) {
    state = loc;
  }
}

final langPro = StateNotifierProvider<LangProviderNotifier, Locale>(
  (_) => LangProviderNotifier(),
);
