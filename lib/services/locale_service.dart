import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'app_locale';

  static Future<Locale?> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) {
      return Locale(code);
    }
    return null;
  }

  static Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }

  static Future<bool> hasLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_localeKey);
  }
}
