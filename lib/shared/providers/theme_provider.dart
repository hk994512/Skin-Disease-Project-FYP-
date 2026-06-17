import 'dart:async';

import 'package:clearskin_ai/core/config.dart';

class ThemeProviderNotifier extends StateNotifier<bool> {
  ThemeProviderNotifier() : super(false);

  bool toggleTheme(bool isDarkMode) {
    if (isDarkMode) {
      state = true;
      return state;
    } else {
      state = false;
      return state;
    }
  }

  String setterKey = 'isDarkMode';
  bool get savedkey => state;

  Future<bool> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(setterKey, state);
  }

  Future<String>? loadThemeData() async {
    final prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(setterKey) ?? '';
    setterKey = value;
    return setterKey;
  }
}

final appThemeProvider = StateNotifierProvider<ThemeProviderNotifier, bool>(
  (fn) => ThemeProviderNotifier(),
);
