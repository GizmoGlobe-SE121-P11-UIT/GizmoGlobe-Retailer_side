import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  late SharedPreferences _prefs;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get currentLanguage => _locale.languageCode;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLocale = _prefs.getString(_localeKey);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'vi') {
      return;
    }
    _locale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  void toggleLanguage() {
    final newLocale =
        _locale.languageCode == 'en' ? const Locale('vi') : const Locale('en');
    setLocale(newLocale);
  }
}
